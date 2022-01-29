@ Thumb2 sierzoom

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
	movw	r6,#:lower16:data_begin
	movt	r6,#:upper16:data_begin

	movs	r8,#-511

forever_loop:

	movs	r4,#0		@ Y
yloop:
	movs	r3,#0		@ X
xloop:
	mul	r2,r3,r8		@ use mla?
	sub	r2,r4,r2, LSR #8
	mul	r5,r4,r8
	add	r5,r3,r5, LSR #8
	ands	r2,r2,r5

	lsrs	r2,#4

	ite	eq
	moveq	r5,#'2'			@ green
	movne	r5,#'0'			@ black

	movs	r1,r6
	strb	r5,[r1,3]		@ patch string with 2/0
	movs	r2,#6			@ length in r2

	cbnz	r1,skip_lf
	adds	r2,r2,#1		@ tack linefeed on end
skip_lf:

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	movs	r0,#STDOUT
	movs	r7,#SYSCALL_WRITE
	swi	#0

	adds	r3,r3,#1			@ decrement X
	cmp	r3,#79
	bne	xloop

	adds	r4,r4,#1			@ increment Y
	cmp	r4,#24
	bne	yloop

	adds	r8,r8,#8

	movs	r0,#STDOUT
	add	r1,r6,#7
	movs	r2,#6
	movs	r7,#SYSCALL_WRITE
	swi	#0

	b	forever_loop


data_begin:

color_string:
	.ascii	"\033[40m "
linefeed:
	.ascii	"\n"
clear_string:
	.ascii	"\033[1;1H"

