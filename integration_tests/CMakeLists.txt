cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(lfort C Fortran)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug
        CACHE STRING "Build type (Debug, Release)" FORCE)
endif ()

set(LFORTRAN_BACKEND no CACHE STRING "Only compile the LFortran subset for the given backend")
set(FAST no CACHE BOOL "Run supported tests with --fast")

enable_testing()

message("\n")
message("Configuration results")
message("---------------------")
message("Fortran compiler: ${CMAKE_Fortran_COMPILER}")
message("C compiler      : ${CMAKE_C_COMPILER}")
message("Build type: ${CMAKE_BUILD_TYPE}")
string(TOUPPER "${CMAKE_BUILD_TYPE}" BTYPE)
message("Fortran compiler flags: ${CMAKE_Fortran_FLAGS_${BTYPE}}")
message("C compiler flags      : ${CMAKE_C_FLAGS_${BTYPE}}")
message("Installation prefix: ${CMAKE_INSTALL_PREFIX}")
message("LFORTRAN_BACKEND: ${LFORTRAN_BACKEND}")
message("FAST: ${FAST}")


macro(RUN_UTIL RUN_FAIL RUN_NAME RUN_FILE_NAME RUN_LABELS RUN_EXTRAFILES RUN_EXTRA_ARGS RUN_COPY_TO_BIN RUN_GFORTRAN_ARGS)
    set(fail ${${RUN_FAIL}})
    set(name ${${RUN_NAME}})
    set(file_name ${${RUN_FILE_NAME}})
    set(labels ${${RUN_LABELS}})
    set(extra_files ${${RUN_EXTRAFILES}})
    set(extra_args ${${RUN_EXTRA_ARGS}})
    set(copy_to_bin ${${RUN_COPY_TO_BIN}})
    set(gfortran_args ${${RUN_GFORTRAN_ARGS}})

    if (NOT name)
        message(FATAL_ERROR "Must specify the NAME argument")
    endif()

    if (LFORTRAN_BACKEND)
        if (${LFORTRAN_BACKEND} IN_LIST labels)
            # Test is supported by the given LFortran backend
            set(ADD_TEST ON)
        else()
            # Test is not supported by the given LFortran backend
            set(ADD_TEST OFF)
        endif()
    else()
        # GFortran
        if ("gfortran" IN_LIST labels)
            set(ADD_TEST ON)
        elseif ("gfortranImplicitArgument" IN_LIST labels)
            set(ADD_TEST ON)
        else()
            set(ADD_TEST OFF)
        endif()
    endif()

    if (ADD_TEST)
        if ((LFORTRAN_BACKEND STREQUAL "cpp") OR (LFORTRAN_BACKEND STREQUAL "x86")
                OR (LFORTRAN_BACKEND STREQUAL "c") OR (LFORTRAN_BACKEND STREQUAL "fortran"))
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC ${extra_args} --backend=${LFORTRAN_BACKEND})
            target_link_options(${name} PUBLIC --backend=${LFORTRAN_BACKEND})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "wasm")
            # wasm test
            execute_process(COMMAND lfortran ${extra_args} --backend=wasm ${CMAKE_CURRENT_SOURCE_DIR}/${file_name}.f90 -o ${name})

            find_program(WASM_EXEC_RUNTIME node)
            execute_process(COMMAND "${WASM_EXEC_RUNTIME}" --version
                            OUTPUT_VARIABLE WASM_EXEC_VERSION
                            OUTPUT_STRIP_TRAILING_WHITESPACE)

            string(REGEX REPLACE "v([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1" NODE_MAJOR_VERSION "${WASM_EXEC_VERSION}")

            if (NODE_MAJOR_VERSION LESS 16)
                message(STATUS "${WASM_EXEC_RUNTIME} version: ${WASM_EXEC_VERSION}")
                set(WASM_EXEC_FLAGS "--experimental-wasm-bigint")
            endif()
            set(WASM_EXEC_FLAGS ${WASM_EXEC_FLAGS} "--experimental-wasi-unstable-preview1")
            add_test(${name} ${WASM_EXEC_RUNTIME} ${WASM_EXEC_FLAGS} ${CURRENT_BINARY_DIR}/${name}.js)
        elseif (LFORTRAN_BACKEND STREQUAL "llvm2")
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC --generate-object-code ${extra_args})
            target_link_options(${name} PUBLIC  --generate-object-code ${extra_args})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "llvm_rtlib")
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC --generate-object-code ${extra_args})
            set_source_files_properties(${file_name}.f90 PROPERTIES COMPILE_OPTIONS "--rtlib")
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "llvmImplicit")
            execute_process(COMMAND lfortran ${CMAKE_CURRENT_SOURCE_DIR}/${file_name}.f90
                ${extra_args} --implicit-typing --implicit-interface -o ${name})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "llvmStackArray")
            execute_process(COMMAND lfortran ${CMAKE_CURRENT_SOURCE_DIR}/${file_name}.f90
                ${extra_args} --stack-arrays=true -o ${name})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "llvm_nopragma")
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC --ignore-pragma ${extra_args})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "c_nopragma")
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC --backend=c --ignore-pragma ${extra_args})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "llvm")
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC ${extra_args})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        elseif (LFORTRAN_BACKEND STREQUAL "gfortranModfileCompilation")
            execute_process(COMMAND gfortran ${CMAKE_CURRENT_SOURCE_DIR}/${file_name}.f90 -c)
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        else ()
            add_executable(${name} ${file_name}.f90 ${extra_files})
            target_compile_options(${name} PUBLIC ${gfortran_args})
            add_test(${name} ${CURRENT_BINARY_DIR}/${name})
        endif()

        if (labels)
            set_tests_properties(${name} PROPERTIES LABELS "${labels}")
        endif()

        if (fail)
            set_tests_properties(${name} PROPERTIES WILL_FAIL TRUE)
        endif()

        if (copy_to_bin)
            file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/${copy_to_bin} DESTINATION ${CURRENT_BINARY_DIR})
        endif()
    endif()
endmacro(RUN_UTIL)

macro(RUN)
    set(options FAIL NOFAST)
    set(oneValueArgs NAME INCLUDE_PATH  COPY_TO_BIN)
    set(multiValueArgs LABELS EXTRAFILES EXTRA_ARGS GFORTRAN_ARGS)
    cmake_parse_arguments(RUN "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN} )

    foreach(b ${RUN_LABELS})
        if (NOT (b MATCHES "^(llvm|llvm2|llvm_rtlib|c|cpp|x86|wasm|gfortran|llvmImplicit|llvmStackArray|fortran|c_nopragma|llvm_nopragma)$"))
            message(FATAL_ERROR "Unsupported backend: ${b}")
        endif()
    endforeach()

    set(RUN_FILE_NAME ${RUN_NAME})

    if (RUN_INCLUDE_PATH)
        # Only one include path supported for now
        # Later add support for multiple include paths by looping over and appending to extra args
        set(RUN_EXTRA_ARGS ${RUN_EXTRA_ARGS} -I${CMAKE_CURRENT_SOURCE_DIR}/${RUN_INCLUDE_PATH})
        set(RUN_GFORTRAN_ARGS ${RUN_GFORTRAN_ARGS} -I${CMAKE_CURRENT_SOURCE_DIR}/${RUN_INCLUDE_PATH})
    endif()

    if (NOT FAST)
        RUN_UTIL(RUN_FAIL RUN_NAME RUN_FILE_NAME RUN_LABELS RUN_EXTRAFILES RUN_EXTRA_ARGS RUN_COPY_TO_BIN RUN_GFORTRAN_ARGS)
    endif()

    if ((FAST) AND (NOT RUN_NOFAST))
        set(RUN_EXTRA_ARGS ${RUN_EXTRA_ARGS} --fast)
        set(RUN_NAME "${RUN_NAME}_FAST")
        list(REMOVE_ITEM RUN_LABELS gfortran) # remove gfortran from --fast test
        RUN_UTIL(RUN_FAIL RUN_NAME RUN_FILE_NAME RUN_LABELS RUN_EXTRAFILES RUN_EXTRA_ARGS RUN_COPY_TO_BIN RUN_GFORTRAN_ARGS)
    endif()
endmacro(RUN)

# only compiles till object file
# to make sure that the ASR generation is successful
macro(COMPILE)
    set(oneValueArgs NAME)
    set(multiValueArgs COMPILERS)
    cmake_parse_arguments(COMPILE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(name ${COMPILE_NAME})
    set(compilers ${COMPILE_COMPILERS})
    if (NOT name)
        message(FATAL_ERROR "Must specify the NAME argument")
    endif()

    if (NOT compilers)
        message(FATAL_ERROR "Must specify the COMPILER argument")
    endif()

    foreach(compiler ${compilers})
        if (compiler STREQUAL "lfortran" AND ${LFORTRAN_BACKEND} STREQUAL "llvm")
            add_custom_command(
                OUTPUT ${name}_lfortran.mod
                COMMAND lfortran -c ${CMAKE_CURRENT_SOURCE_DIR}/${name}.f90)
            add_library(${name}_lfortran OBJECT ${name}_lfortran.mod)
        elseif(compiler STREQUAL "gfortran" AND ${LFORTRAN_BACKEND} STREQUAL "no")
            add_custom_command(
                OUTPUT ${name}_gfortran.mod
                COMMAND gfortran -c ${CMAKE_CURRENT_SOURCE_DIR}/${name}.f90)
            add_library(${name}_gfortran OBJECT ${name}_gfortran.mod)
        endif()
    endforeach()
endmacro(COMPILE)

# The supported test labels are:
#
# gfortran      --- compile with GFortran
# fortran       --- convert to Fortran code and compile with GFortran
# llvm          --- compile with LFortran, only generate binary code at the very end
# llvm2         --- compile with LFortran, generate object files
# llvm_rtlib    --- compile with LFortran loading ASR runtime library, generate object files
# cpp           --- compile to C++, compile C++ to binary
# x86           --- compile to x86 binary directly
# wasm          --- compile to WASM binary directly

# `reduce` is not supported by GFortran yet:
# RUN(NAME doconcurrentloop_02 LABELS gfortran)

# GFortran + LFortran LLVM + LFortran C++

#RUN(NAME template_matrix_01 LABELS llvm)
RUN(NAME template_matrix_real LABELS llvm EXTRAFILES
    template_semigroup.f90
    template_semiring.f90
    template_monoid.f90
    template_unitring.f90
    template_field.f90
    template_matrix.f90
    EXTRA_ARGS --module-mangling
    )
RUN(NAME template_matrix_integer LABELS llvm EXTRAFILES
    template_semigroup.f90
    template_semiring.f90
    template_monoid.f90
    template_unitring.f90
    template_field.f90
    template_matrix.f90
    EXTRA_ARGS --module-mangling
    )

#RUN(NAME common_02 LABELS gfortran llvm)
#RUN(NAME common_12 LABELS gfortran llvm llvmImplicit)
