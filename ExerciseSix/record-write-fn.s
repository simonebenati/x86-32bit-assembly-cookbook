.include "program-common.s"
.include "linux-common.s"

#PURPOSE: This function reads a record from the file desriptor
#INPUT: The file descriptor and a buffer
#OUTPUT: This fun ction writes teh data to the buffer and returns a status code.

#STACK LOCAL VARS
.equ ST_READ_BUFFER, 8
.equ ST_FILEDES, 12
.section .text
.globl read_record
.type read_record, @function
read_record:
  pushl %ebp
  movl %esp, %ebp

  pushl %ebx
  movl ST_FILEDES(%ebp), %ebx
  movl ST_READ_BUFFER(%ebp), %ecx
  movl $SYS_READ, %eax
  int $LINUX_SYSCALL

#NOTE - %eax has the return value, which we will give back to our calling program
popl %ebx
movl %ebp, %esp
popl %ebp
ret

#PURPOSE: This function writes a record to the file descriptor
#INPUT: The file descriptor anda  buffer
#OUTPUT: This function produces a status code
#STACK LOCAL VARIABLES

.equ ST_WRITE_BUFFER, 8
.equ ST_FILEDES, 12
.section .text
.globl write_record
.type write_record, @function
write_record:
  pushl %ebp
  movl %esp, %ebp
  pushl %ebx
  movl $SYS_WRITE, %eax 
  movl ST_FILEDES(%ebp), %ebx
  movl ST_WRITE_BUFFER(%ebp), %ecx
  movl $RECORD_SIZE, %edx
  int $LINUX_SYSCALL
  #NOTE - %eax has the return value, which we will give back to our calling program
  popl %ebx
  movl %ebp, %esp
  popl %ebp
  ret

