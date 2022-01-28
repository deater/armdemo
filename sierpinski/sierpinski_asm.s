@ Thumb2 sierpinski

.syntax unified
#.arm
.thumb

# Syscalls
.equ SYSCALL_EXIT,	1
.equ SYSCALL_WRITE,	4
.equ SYSCALL_NANOSLEEP,	162
#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

        .globl _start
_start:

	movs	r4,#0		@ Y
forever_loop:
	movs	r3,#0		@ X
xloop:

	ands	r5,r3,r4
	beq	black
green:
	ldr	r1,=green_string
	b	done
black:
	ldr	r1,=black_string
done:
	movs	r2,#6
	bl	write_stdout

	adds	r3,r3,#1
	cmp	r3,#79
	bne	xloop

	movs	r2,#1
	ldr	r1,=linefeed
	bl	write_stdout

	adds	r4,r4,#1

	@ usleep(10000);

	ldr	r0,=time				@ blurgh
	movs	r1,0
	movs	r7,#SYSCALL_NANOSLEEP
	swi	#0

	b	forever_loop

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	push	{r3,r4}
	movs	r0,#STDOUT
	movs	r7,#SYSCALL_WRITE
	swi	#0
	pop	{r3,r4}
	bx	lr

        #================================
        # Exit
        #================================
exit:
	movs	r0,#5
	movs	r7,#SYSCALL_EXIT	@ put exit syscall number (1) in r7
	swi	#0			@ and exit

green_string:
	.ascii	"\033[40m "
black_string:
	.ascii	"\033[42m "
linefeed:
	.ascii	"\n"

time:
	.word	0,30000000
