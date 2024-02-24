
program expr2
implicit none

character(len=20) :: str
str =  to_string_1_i_int32(-123)
print *, str

contains

    function to_string_1_i_int32(value) result(string)
        integer, intent(in) :: value
        character(len=20) :: string
        integer, parameter :: buffer_len = range(value)+2
        character(len=buffer_len) :: buffer
        integer :: pos
        integer :: n, tmp
        character(len=1) :: numbers(-9:0)
        numbers = &
            ["9", "8", "7", "6", "5", "4", "3", "2", "1", "0"]

        if (value == 0) then
            string = numbers(0)
            return
        end if

        n = sign(value, -1)
        buffer = ""
        pos = buffer_len + 1
        do while (n < 0)
            pos = pos - 1
            tmp = mod(n, 10)
            buffer(pos:pos) = numbers(tmp)
            n = n/10
        end do

        if (value < 0) then
            pos = pos - 1
            buffer(pos:pos) = '-'
        end if

        string = buffer(pos:)
    end function to_string_1_i_int32

end program
