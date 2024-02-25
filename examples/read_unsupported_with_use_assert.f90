module my_mod

    type :: my_type
        sequence
        integer :: a
    end type
    interface read(unformatted)
        module procedure :: read_unformatted
    end interface

    interface read(formatted)
        module procedure :: read_formatted
    end interface

    contains

    subroutine read_unformatted(mt, unit, iostat, iomsg)
        type(my_type), intent(inout) :: mt
        integer, intent(in)    :: unit
        integer, intent(out)   :: iostat
        character(len=*), intent(inout) :: iomsg

        mt%a = 125
    end subroutine read_unformatted

    subroutine read_formatted(mt, unit, iotype, v_list, iostat, iomsg)
        type(my_type), intent(inout) :: mt
        integer, intent(in) :: unit
        character(len=*), intent(in) :: iotype
        integer, intent(in) :: v_list(:)
        integer, intent(out) :: iostat
        character(len=*), intent(inout) :: iomsg

        mt%a = 125
    end subroutine

end module

program expr2
    use my_mod, only: my_type, read(formatted)
    implicit none

    type(my_type) :: mt
    integer :: io
    mt%a = 10
    print *, mt%a
    ! read(*, *) mt
    ! print *, mt%a


    open(newunit=io, form="unformatted", file="tmp.txt")
    write(io) 125
    close(io)

    open(newunit=io, form="formatted", file="tmp.txt")
    read(io, *) mt
    print *, mt%a
    close(io)
end program
