
program expr2
    implicit none

    character(len=25) :: str
    str =  to_string_1_i_int64(921092378411_8)
    print *, str

    contains

    function to_string_1_i_int64(value) result(string)
        integer(8), intent(in) :: value
        character(len=:), allocatable :: string
        integer, parameter :: buffer_len = range(value)+2
        character(len=buffer_len) :: buffer
        integer :: pos
        integer(8) :: n
        character(len=1) :: numbers(-9:0)
        numbers = ["9", "8", "7", "6", "5", "4", "3", "2", "1", "0"]

        if (value == 0_8) then
            string = numbers(0)
            return
        end if

        n = sign(value, -1_8)
        buffer = ""
        pos = buffer_len + 1
        print *, n, pos, "good here - 0"
        do while (n < 0_8)
            pos = pos - 1
            print *, pos, n, "good here - 1"
            print *, "issue: ", n, mod(n, 10_8)
            buffer(pos:pos) = numbers(mod(n, 10_8))
            print *, "added to numbers"
            n = n/10_8
        end do
        print *, n, pos, "good here - 1"

        if (value < 0_8) then
            pos = pos - 1
            buffer(pos:pos) = '-'
        end if

        string = buffer(pos:)
    end function to_string_1_i_int64

end program
