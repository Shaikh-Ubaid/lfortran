
program expr2
    implicit none

    character(len=10) :: bool

    write(bool, '(g0)') .true.
    print *, bool

    if (bool /= 'T') error stop

end program
