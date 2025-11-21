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

#STACK POSITIONS

.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, 0
.equ ST_FD_OUT, 4
.equ ST_ARGC, 8 # position of the number of arguments
.equ ST_ARGV_0, 12 # position for the name of the program
.equ ST_ARGV_1, 16 # position for the input of the filename
.equ ST_ARGV_2, 20 # position for the output of the file name

.globl _start
_start:
    ### INITIALIZE PROGRAM ###
    subl $ST_SIZE_RESERVE, %esp #Allocate space for our pointers on the stack
    movl %esp, %ebp

    open_files:
    open_fd_in:
        movl ST_ARGV_1(%ebp), %ebx #input filename into %ebx
        movl $O_RDONLY, %ecx #read-only flag
        movl $0666, %edx #permissions, althought doesn't really matter for reading
        movl $OPEN, %eax #open syscall (setting eax to number 5 in order to call appropriate syscall)
        int $LINUX_SYSCALL 

    store_fd_in:
        movl %eax, ST_FD_IN(%ebp) #linux syscall returns the number of the file descriptor given by the kernel. we save it.

    open_fd_out:
        ###OPEN OUTPUT FILE###
        movl ST_ARGV_2(%ebp), %ebx #output filename into %ebx
        movl $O_CREAT_WRONLY_TRUNC, %ecx #flags for writing to the file
        movl $0666, %edx #assigning permissions to the new created file, if created
        movl $OPEN, %eax #open the file
        int $LINUX_SYSCALL #call kernel linux

    store_fd_out:
        movl %eax, ST_FD_OUT(%ebp)  #store the returned file descriptor

    ### MAIN LOOP STARTS ###
    read_loop_begin:
    ### READ IN A BLOCK FROM THE INPUT FILE ###
        movl ST_FD_IN(%ebp), %ebx     #get the input file descriptor, (meaning where to read)
        movl $BUFFER_DATA, %ecx     #the location to read into, preallocated in .bss section
        movl $BUFFER_SIZE, %edx     #the size of the buffer (allocated in .bss these need to match in order to avoid reading from values in other addresses)
        movl $READ, %eax        #prepare for syscall with appropriate number
        int $LINUX_SYSCALL
                            #size of buffer read is returned in %eax
    ### EXIT IF WE REACHED THE END###
        cmpl $END_OF_FILE, %eax
        jle end_loop            #if eax is smaller or equal to 0 (END_OF_FILE) we jump to exit loop.

    continue_read_loop:
    ### CONVERT BLOCK TO UPPER CASE###
        pushl $BUFFER_DATA        #current Location of the buffer
        pushl %eax                #current size of the buffer
        call convert_to_upper
        popl %eax
        popl %ebx
    ###WRITE THE BLOCK OUT TO THE OUTPUT FILE###
        movl ST_FD_OUT(%ebp), %ebx #file to use, we use file descriptor to reference it
        movl $BUFFER_DATA, %ecx    #Location of the buffer
        movl %eax, %edx            #Size of the buffer
        movl $WRITE, %eax
        int $LINUX_SYSCALL


    ###CONTINUE THE LOOP###
        jmp read_loop_begin

    end_loop:
    ### CLOSE THE FILES###
    #NOTE - we don't need to do error check on these, because error conditions don't mean anything special here
        movl ST_FD_OUT(%ebp), %ebx
        movl $CLOSE, %eax
        int $LINUX_SYSCALL

        movl ST_FD_IN(%ebp), %ebx
        movl $CLOSE, %eax
        int $LINUX_SYSCALL

    ###EXIT###
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

    convert_to_upper:
        pushl %ebp
        movl %esp, %ebp

    ###SET UP VARIABLES###
        movl ST_BUFFER(%ebp), %eax
        movl ST_BUFFER_LEN(%ebp), %ebx
        movl $0, %edi

    #if a buffer with zero length was given us, just leave
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
        #no return value, just leave
            movl %ebp, %esp
            popl %ebp
            ret


