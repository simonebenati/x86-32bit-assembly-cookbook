# PURPOSE: This program converts an input file to an output file with all letters converted to uppercase.

# PROCESSING: 1) Open the input file
#             2) Open the output file
#             3) While we're not at the end of the input file:
#                a) Read a chunk of data from the input flexible
#                b) Go through each byte of memory, if the byte is a lower-case letter, convert it to uppercase
#                c) Write the modified chunk to the output flexible

.section .data #not used but written for completeness

#### CONSTANTS ####

.equ OPEN, 5
.equ WRITE, 4
.equ READ, 3
.equ CLOSE, 6
.equ EXIT, 1
.equ FD_STDIN, 0
.equ FD_STDOUT, 1
.equ ST_SIZE_RESERVE, 4
#options for opening a file
#
#

.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101 #Open file options for read only mode
                                 #Open files options:
                                 #CREAT - create file if it doesn't exists
                                 #WRONLY - we will only write to this file, not read
                                 #TRUNC - destroy/overwrite current file contents, if any previous exists

#system call interrupt
.equ LINUX_SYSCALL, 0x80

#end-of-file result status
.equ END_OF_FILE, 0 #this is the return value of read() which means we've hit the end of the file


#### BUFFERS ####
.section .bss
#This is where the data is loaded into from the data file and written from into the output file.
#This should never exceed 16000 bytes for various reasons (32-bit).
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

#### PROGRAM CODE ####

.section .text

.globl _start
_start:
    ### INITIALIZE PROGRAM ###
    subl $ST_SIZE_RESERVE, %esp #Allocate space for our pointers on the stack
    movl %esp, %ebp

    input_stdin:
        movl $FD_STDIN, %ebx #input filename into %ebx
        movl $BUFFER_DATA, %ecx #read-only flag
        movl $BUFFER_SIZE, %edx #permissions, althought doesn't really matter for reading
        movl $READ, %eax #open syscall (setting eax to number 5 in order to call appropriate syscall)
        int $LINUX_SYSCALL 
    string_manipulation:
      pushl %eax #this is buffer size (the size from stdin)
      pushl $BUFFER_DATA
      call to_uppercase
    out_stdout:
        ###OPEN OUTPUT FILE###
        movl $FD_STDOUT, %ebx #output filename into %ebx
        movl $BUFFER_DATA, %ecx #flags for writing to the file
        popl %edx #assigning permissions to the new created file, if created
        movl $WRITE, %eax #open the file
        int $LINUX_SYSCALL #call kernel linux

    #store_fd_out:
    #    movl %eax, ST_FD_OUT(%ebp)  #store the returned file descriptor

    movl $0, %ebx
    movl $EXIT, %eax
    int $LINUX_SYSCALL

    ###FUNCTION convert_to_upper
    #
    # PURPOSE: This function actually does the conversion to upper case for a block
    #
    # INPUT: The first paramter is the location of the block of memory
    #        The second paramter is the length of that buffer
    #
    # OUTPUT: This function overwrites the current buffer with the upper-caseified version
    #
    #
    # VARIABLES:
    #
    # %eax - beginning of the buffer
    # %ebx - length of the buffer
    # %edi - current buffer offset
    # %cl - current byte being examined (%cl is the first byte of %ecx)


    ###CONSTANTS###
    .equ LOWERCASE_A, 'a'
    .equ LOWERCASE_Z, 'z'
    .equ UPPER_CONVERSION, 'A' - 'a'

    ###STACK POSITIONS###
    .equ ST_BUFFER_LEN, 8 #Length of buffer
    .equ ST_BUFFER, 12 #Actual buffer
  to_uppercase:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %eax #this is buffer data, meaning how many bytes we read from stdin
    movl 12(%ebp), %ebx #this is the pointer to the memory reserved for buffer 
    cmpl $0, %ebx
    je end_convert_loop
    convert_loop:
        #get the current byte
        movb (%eax,%edi,1), %cl
        #go to the next byte unless it's bettween 'a' and 'z'
        cmpb $LOWERCASE_A, %cl
        jl next_byte
        cmpb $LOWERCASE_Z, %cl
        jg next_byte
        #otherwise concvert the byte to uppercase
        addb $UPPER_CONVERSION, %cl
        #and store it back
        movb %cl, (%eax,%edi,1)
    next_byte:
      incl %edi   #next byte
      cmpl %edi, %ebx #continue unless we've reached the end
      jne convert_loop  
    end_convert_loop:
      movl %ebp, %esp
      popl %ebp
      ret




