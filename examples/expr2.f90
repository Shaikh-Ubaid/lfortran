
program expr2
implicit none

! character(len=1) :: str

! write(str, '(g0)') "A"
! print *, "|"//str//"|"

    character(len=100) :: warn1
    write(warn1, '(a,1x,a,1x,a,1x,a)') 'KEYWORD', 'SHORT', 'PRESENT', 'VALUE'
    print*, "!", warn1, "!"

end program
