@ Thumb2 sierzoom

XWIDTH = 128
YHEIGHT = 50

@ Optimization
@ 208 bytes -- initial implementation (smaller than I thought it'd be)
@ 251 bytes -- clear screen, add desire logo
@ 246 bytes -- load at 0x8054
@ 231 bytes -- make a 16-bit encoding pass

.syntax unified
#.arm
.thumb

# Syscalls
.equ SYSCALL_EXIT,	1
.equ SYSCALL_WRITE,	4
#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

        .globl _start
_start:
	movw	r6,#:lower16:data_begin
@	movt	r6,#:upper16:data_begin		@ not needed we load to 0x8054

	mov	r8,#-4097			@ fits, unline -4096

	@ clear screen and print desire string

	@ r0 already 0
	movw	r1,#:lower16:dsr_string
	movs	r2,#28
	bl	write_stdout

forever_loop:

	adds.n	r1,r6,#7		@ point to home cursor
	movs	r2,#6
	bl	write_stdout

	movs	r4,#0		@ Y
yloop:
	movs	r3,#0		@ X
xloop:
	mul	r2,r3,r8		@ X * frame
	sub	r2,r4,r2, ASR #8	@ Y - (x*frame)/256
	mul	r5,r4,r8		@ Y * frame
	add	r5,r3,r5, ASR #8	@ X + (y*frame)/256
	ands	r2,r2,r5

	ands	r2,#0xf0		@ color

	ite	eq
	moveq	r5,#'2'			@ green if color=0
	movne	r5,#'0'			@ black else

	movs	r1,r6
	strb	r5,[r1,3]		@ patch string with 2/0

	lsrs	r2,#4
	adds	r2,r2,#' '
	strb	r2,[r1,5]		@ patch output char

	movs	r2,#6			@ length in r2

	cmp	r3,#XWIDTH-1
	bne	skip_lf
	adds	r2,r2,#1		@ tack linefeed on end
skip_lf:

	bl	write_stdout

	adds	r3,r3,#1			@ decrement X
	cmp	r3,#XWIDTH
	bne	xloop

	adds	r4,r4,#1			@ increment Y
	cmp	r4,#YHEIGHT
	bne	yloop

	add	r8,r8,#8


	b	forever_loop

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	movs	r0,#STDOUT
	movs	r7,#SYSCALL_WRITE
	swi	#0
	blx	lr

data_begin:

color_string:
	.ascii	"\033[40m "
linefeed:
	.ascii	"\n"
clear_string:
	.ascii	"\033[1;1H"

@wave_string:
@	.ascii " .:'!|!':. "
dsr_string:
	@ 113/2 = 56
	.ascii "\033[2J\033[53;56H- d e s i r e -\n"
