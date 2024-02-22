program expr2
implicit none

integer :: stat
real :: value = 3.14
character(len=128) :: buffer

write(buffer, '(F6.2)', iostat=stat) value
print *, buffer, stat

end program
