
program expr2
implicit none

integer :: value = -123
character(len=:), allocatable :: string
integer, parameter :: buffer_len = range(value)+2
character(len=buffer_len) :: buffer
integer :: pos
integer :: n
character(len=1), parameter :: numbers(-9:0) = &
    ["9", "8", "7", "6", "5", "4", "3", "2", "1", "0"]

if (value == 0) then
    string = numbers(0)
    print *, string
    stop
end if

print *, "here - 0"
n = sign(value, -1)
print *, "here - 0.1", n
buffer = ""
print *, "buffer_len", buffer_len
pos = buffer_len + 1
do while (n < 0)
    pos = pos - 1
    buffer(pos:pos) = numbers(mod(n, 10))
    n = n/10
end do

print *, "pos", pos, "n", n
print *, "here - 1"
if (value < 0) then
    pos = pos - 1
    buffer(pos:pos) = '-'
end if

print *, "here - 2"
string = buffer(pos:)

print *, string, pos

contains

end program
