program main

    character(len=100) :: warn1
    write(warn1, '(a,1x,a,1x,a,1x,a)') 'KEYWORD', 'SHORT', 'PRESENT', 'VALUE'
    print*, "!", warn1, "!"
end program
