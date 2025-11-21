#PURPOSE: This program finds the maximum number of a set of data items.
#
#

#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest  data item found
# %eax - Current data item
# 
# The following memory locations are used:
# 
# data_items - contains the item data. A 0 is used to terminate the data
#

.section .data
data_items:                         #These are the data items
 .long 81,67,34,222,45,75,54,34,44,33,22,255,11,66,255

.section .text

.globl _start
_start:
movl $0, %edi              # move 0 into the index register
movl data_items(,%edi,4), %eax      # load the first byte of data
movl %eax, %ebx              # "pre-allocate" maximum value in the register that will hold max value

start_loop:                  # start looping
    incl %edi
    movl data_items(,%edi,4), %eax
    cmpl $255, %eax            # are we at the end of the array? is the value of register %eax 0?
    je loop_exit
    #incl %edi                #loads next value
    #movl data_items(,%edi,4), %eax
    cmpl %ebx, %eax          # compare maximum with current value
    jge start_loop           # back to start if current value isn't bigger than max

    movl %eax, %ebx          # move the value as the biggest, ebx tracks max value
    jmp start_loop           # back to start loop

loop_exit:
    # %ebx is the value to return 
    movl $1, %eax           # we're syscalling to exit program
    int $0x80
