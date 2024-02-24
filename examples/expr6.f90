program main
    call hello()

    contains

    subroutine hello()
        character(len=1), parameter :: numbers(-9:0) = &
            ["9", "8", "7", "6", "5", "4", "3", "2", "1", "0"]
        integer :: n
        n = -1
        print *, "hi: ", numbers(n)
        n = -3
        print *, "hi: ", numbers(n)
    end subroutine

end program
