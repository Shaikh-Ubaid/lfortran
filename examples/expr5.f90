program main

    integer :: n, cnt
    n = -123
    cnt = 0

    do while (n < 0)
        cnt = cnt + 1
        n = n/10
    end do

    print *, cnt, n

    if (n /= 0) error stop

end program
