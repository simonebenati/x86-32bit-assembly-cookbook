#PURPOSE: Program to illustrate how assembly functions work
#         This program will compute the value of 2^3 + 5^2
#
#
#Everything in the main program is stored in registers,
#so the data section doesn't have anything to store.
.section .data

.section .text
.globl _start
    _start:
        pushl $0        #push second argument (exponent)
        pushl $2        #push first argument (base)
        call power      #call the function
        addl $8, %esp   #move the stack pointer back (8 bytes for 2 pushes)
        pushl %eax      #save the first answer
                        #before calling the next function
        pushl $0        #now save the second function call second argument
        pushl $2        #push the second function call first argument
        call power      #call the function
        addl $8, %esp   #move the stack pointer back
        popl %ebx       #The second answer is already in %eax

        addl %eax, %ebx

        movl $1, %eax   #syscall number for exit (32-bit Linux)
        int $0x80       #32-bit syscall instruction

#PURPOSE: This function is used to compute the value of a number raised to a power.
#
#
#INPUT: First argument - the base power
#       Second argument - the power to raise it to
#
#
#OUTPUT: Will give the result as a return value
#
#NOTE: The power must be 1 or greater
#
#VARIABLES:
#   %ebx - holds the base number
#   %ecx - holds the power
#   -4(%ebp) - holds the current result
#   %eax is used for temporary storage
#
.type power, @function
    power:
        pushl %ebp          #save old base pointer
        movl %esp, %ebp     #make stack pointer the base pointer
        subl $4, %esp       #make room for our local storage
        
        movl 8(%ebp), %ebx  #put the first argument in %ebx
        movl 12(%ebp), %ecx #put the second argument in %ecx
        cmpl $0, %ecx
        je end_power_if_zero
        movl %ebx, -4(%ebp) #store the current result
        power_loop_start:
            cmpl $1, %ecx       #check if power to scale to is 1, exit immediately
            je end_power
            movl -4(%ebp), %eax #move the current result into %eax
            imul %ebx, %eax    #multiply the current result by the base number
            movl %eax, -4(%ebp) #store back to memory
            decl %ecx           #decrease the power
            jmp power_loop_start
        end_power:
            movl -4(%ebp), %eax #return value goes in %eax
            movl %ebp, %esp     #restore the stack pointer
            popl %ebp           #restore the base pointer
            ret
        end_power_if_zero:
            movl $1, %eax
            movl %ebp, %esp
            popl %ebp
            ret
