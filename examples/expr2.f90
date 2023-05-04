module module_01
    implicit none
    contains

    subroutine hi()
        print *, "hi from module_01"
    end subroutine

end module

module module_02
    implicit none
    contains

    subroutine hi()
        print *, "hi from module_02"
    end subroutine

end module

program expr2
use module_02
use module_02

call hi()

end program
