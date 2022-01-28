@ Thumb2 test

.syntax unified
#.arm
.thumb

# Syscalls
.equ SYSCALL_EXIT,     1
.equ SYSCALL_WRITE,	4

#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

        .globl _start
_start:

        #================================
        # Hello
        #================================
hello:
	movs	r0,#STDOUT
	ldr	r1,=hello_string
	movs	r2,#6
	movs	r7,#SYSCALL_WRITE
	swi	#0

        #================================
        # Exit
        #================================
exit:
	movs	r0,#5
	movs	r7,#SYSCALL_EXIT	@ put exit syscall number (1) in r7
	swi	#0			@ and exit

.align 1
hello_string:
	.asciz	"Hello\n"
