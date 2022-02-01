@ Thumb2 sierzoom

XWIDTH = 128
YHEIGHT = 50

@ Optimization
@ 208 bytes -- initial implementation (smaller than I thought it'd be)
@ 251 bytes -- clear screen, add desire logo
@ 246 bytes -- load at 0x8054
@ 231 bytes -- make a 16-bit encoding pass
@ 229 bytes -- use r5 instead of r8
@ 256 bytes -- accidental color change of logo
@ 232 bytes -- rip out the attempt at animated wave
@ 272 bytes -- write a whole line at time (num syscalls / 128)
@		doing this because we were too slow on Linux console
@		oddly it ran much faster over network

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

	mov	r5,#-4097			@ fits, unline -4096

	@ clear screen and print clear/desire string

	movw	r1,#:lower16:clear_string
	movs	r2,#33
	bl	strcat

forever_loop:

	@ print desire string
@	adds	r1,r6,#(wave_string-data_begin)
	adds	r1,r6,#(dsr_string-data_begin)
	movs	r2,#32
	bl	strcat

	movs	r4,#0		@ init Y
yloop:
	movs	r3,#0		@ init X
xloop:
	mul	r2,r3,r5		@ X * frame
	sub	r2,r4,r2, ASR #8	@ Y - (x*frame)/256
	mul	r7,r4,r5		@ Y * frame
	add	r7,r3,r7, ASR #8	@ X + (y*frame)/256
	ands	r2,r2,r7

	ands	r2,#0xf0		@ color

	ite	eq
	moveq	r7,#'2'			@ green if color=0
	movne	r7,#'0'			@ black else

	movs	r1,r6
	strb	r7,[r1,3]		@ patch string with 2/0

	lsrs	r2,#4
	adds	r2,r2,#' '
	strb	r2,[r1,5]		@ patch output char

	movs	r2,#6			@ length in r2

	cmp	r3,#XWIDTH-1
	bne	skip_lf
	adds	r2,r2,#1		@ tack linefeed on end
skip_lf:

	bl	strcat

	adds	r3,r3,#1			@ decrement X
	cmp	r3,#XWIDTH
	bne	xloop

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	mov	r2,r0
	mov	r0,#STDOUT
	movw	r1,#:lower16:out_buffer
	movs	r7,#SYSCALL_WRITE
	swi	#0

	mov	r0,#0

	adds	r4,r4,#1			@ increment Y
	cmp	r4,#YHEIGHT
	bne	yloop

	adds	r5,r5,#8			@ update frame

	b	forever_loop

	@================================
	@ strcat
	@================================
	@ string in r1
	@ len in r2
strcat:
	push	{r3,r4}
	movs	r3,#0
	movw	r4,#:lower16:out_buffer
strcat_loop:
	ldrb	r7,[r1,r3]
	strb	r7,[r4,r0]
	adds	r3,r3,#1
	adds	r0,r0,#1
	subs	r2,r2,#1
	bne	strcat_loop
	pop	{r3,r4}
	blx	lr


data_begin:

color_string:
	.ascii	"\033[40m "		@ 0
linefeed:
	.ascii	"\n"			@ 6
clear_string:
	.ascii "\033[2J"		@ 7
dsr_string:
	@ 113/2 = 56
	@ 32 bytes long
	.ascii "\033[52;55H- d e s i r e -\033[1;1H"

out_buffer:
