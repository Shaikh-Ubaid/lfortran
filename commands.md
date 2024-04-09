clang++ --target=wasm32-wasi main.cpp

clang++ -c --target=wasm32-wasi main.cpp
wasm-ld -L/Users/ubaid/ext/wasi-sdk-19.0/bin/../share/wasi-sysroot/lib/wasm32-wasi /Users/ubaid/ext/wasi-sdk-19.0/bin/../share/wasi-sysroot/lib/wasm32-wasi/crt1-command.o main.o -lc++ -lc++abi -lc /Users/ubaid/ext/wasi-sdk-19.0/lib/clang/15.0.7/lib/wasi/libclang_rt.builtins-wasm32.a -o main.wasm

wasm-ld -L/Users/ubaid/ext/wasi-sdk-19.0/bin/../share/wasi-sysroot/lib/wasm32-wasi /Users/ubaid/ext/wasi-sdk-19.0/bin/../share/wasi-sysroot/lib/wasm32-wasi/crt1-command.o my_main.o lfortran_intrinsics.o -lc++ -lc++abi -lc /Users/ubaid/ext/wasi-sdk-19.0/lib/clang/15.0.7/lib/wasi/libclang_rt.builtins-wasm32.a -o main.wasm



# Extras

/Users/ubaid/ext/wasi-sdk-19.0/bin/clang --target=wasm32-wasi -c lfortran_intrinsics.c -o runtime.o

$HOME/wasi-sdk-12.0/bin/clang --sysroot=$HOME/wasi-sdk-12.0/share/wasi-sysroot -c lfortran_intrinsics.c -o lfruntime_intrinsics_c_wasm32.o
lfortran -c wasm.f90 -o wasm.o --target wasm32
$HOME/wasi-sdk-12.0/bin/wasm-ld --no-entry wasm.o lfruntime_intrinsics_c_wasm32.o -L$HOME/wasi-sdk-12.0/lib/clang/11.0.0/lib/wasi -L$HOME/wasi-sdk-12.0/share/wasi-sysroot/lib/wasm32-wasi -lclang_rt.builtins-wasm32 -lc --export-dynamic --strip-all -o wasm.wasm


# Final Commands

/Users/ubaid/ext/wasi-sdk-19.0/bin/clang -c --target=wasm32-wasi -D_WASI_EMULATED_PROCESS_CLOCKS lfortran_intrinsics.c -o runtime.o

lfortran examples/expr2.f90 --target=wasm32-wasi -c -o /Users/ubaid/Desktop/OpenSource/code-playground/try6/expr2.o

/Users/ubaid/ext/wasi-sdk-19.0/bin/clang -nostartfiles -Wl,--entry=_start -Wl,-lwasi-emulated-process-clocks expr2.o runtime.o -o tmp

wasmtime run tmp --dir=.

wasmer run tmp --mapdir=:.
