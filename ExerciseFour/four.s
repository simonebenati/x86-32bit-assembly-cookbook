#PURPOSE - Given a number, this program computes the factorial.
#           For example, the factorial of 3 is 3 * 2 * , or 6. The factorial of 4 is
#           4 * 3 * 2 * 1 or 24, and so on.
#

#This program shows how to call a function. You call
#a function by first pushing all the arguments,
#then you call the function, and the resulting
#value is in %eax. The program can also change the passed parameters
#if it wants to.
#

.section .data
#empty
.section .text
    .globl _start
    .globl factorial #this is unneeded unless we want to share
                         #this funtion among other programs

    _start:
        pushl $4        #this factorial takes one argument - the number we want a factorial of.
                        # so it gets pushed to the stack

        call factorial  #call factorial piece of code (function)
        popl %ebx       #we pop the returning value from the stack to have it accessible/saved
        movl %eax, %ebx #factorial function returns the answer in register %eax, but we
                        #want to move it in %ebx to send it as our exit status

        movl $1, %eax   #prepare syscalln exit
        int $0x80

#This is the actual function definition
.type factorial, @function
    factorial:
        pushl %ebp          #standard stuff - we have to restore
        movl %esp, %ebp     #ebp to its prior state before returning, so we have to push it/save it to the stack
                            #This is because we don't want to modify the stack pointer, so we use ebp instead.
                            #Also because ebp is more flexible

        movl 8(%ebp), %eax  #Assigning argument into eax. remember 4(%ebp) holds return address (where the func was called from)
                            #8(%ebp) and so on contain the parameters pushed into stack

        cmpl $1, %eax       #Base case, if 1 just return 1
        je end_factorial
        decl %eax           #if not one, decrease the factorial to reach the base case!!!
        pushl %eax          #push the new value to stack to be accessed again from the beginning of the function "factorial"
        call factorial      #recursive call to factorial
        popl %ebx           #store eax in ebx

        incl %ebx
        imul %ebx, %eax

end_factorial:
    movl %ebp, %esp    #standard return syntax, we restore %ebp and %esp to what they were before entering
    popl %ebp          #we pop stack into %ebp so that we return immediately to the address from where the function was called from.

    ret
