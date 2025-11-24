.section .data 
  filepath: .asciz "./heynow.txt"
  file_content: .asciz "Hey diddle diddle!"

.section .bss
  .lcomm BUFFER_DATA, 500

.section .text
.globl _start
_start:
  .equ WRITE, 4
  .equ OPEN, 5
  .equ CLOSE, 6
  .equ EXIT, 1
  .equ LINUX_SYSCALL, 0x80

  movl $OPEN, %eax
  movl $filepath, %ebx 
  movl $03101, %ecx
  movl $0666, %edx
  int $LINUX_SYSCALL
  pushl %eax

  movl $WRITE, %eax
  movl (%esp), %ebx
  movl $file_content, %ecx
  movl $18, %edx
  int $LINUX_SYSCALL

  movl $CLOSE, %eax
  movl (%esp), %ebx
  int $LINUX_SYSCALL

  movl $0, %ebx
  movl $EXIT, %eax
  int $LINUX_SYSCALL

