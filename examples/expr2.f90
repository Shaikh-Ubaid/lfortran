module expr2
implicit none
contains
    real function sum2(x) result(r)
        real, intent(in) :: x(:)
        integer :: i
        r = 0
        do i = 1, size(x)
            r = r + x(i)
        end do
    end function
end module
