### Program that calculates the square root of a given number


.section .data
# Not needed as we will write directly in memory

.section .text
    .globl _start

_start:
    pushl $4
    call rootsqr
    popl %ebx
    movl %eax, %ebx
    movl $1, %eax
    int $0x80

.type rootsqr, @function
    rootsqr:
        pushl %ebp
        movl %esp, %ebp
        movl $1, %eax
        movl $1, %ebx
        start_loop:
            imul %ebx, %eax
            cmpl 8(%ebp), %eax
            je end_loop
            incl %ebx
            movl %ebx, %eax
            jmp start_loop
        end_loop:
           movl %ebx, %eax
           movl %ebp, %esp
           popl %ebp
           ret


