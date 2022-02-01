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
@ 254 bytes -- repotimize, fit in low registers, avoid strcat() call at start
@ 240 bytes -- optimize back to all fit in 8 registers

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

@ register allocation
@ r0 = length to strcat()
@ r1 = input to strcat()
@ r2 = out_buffer length
@ r3 = X
@ r4 = Y
@ r5 = frame
@ r6 = out_buffer pointer
@ r7 = temp

        .globl _start
_start:
	movw	r6,#:lower16:out_buffer		@ don't need to load top
						@ as we live below 0x10000

	mov	r5,#-4097			@ fits, unlike -4096

	@ start with clear_screen in string buffer

	movs	r2,#4

forever_loop:

	@ print desire string
@	adds	r1,r6,#(dsr_string-data_begin)
	movw	r1,#:lower16:dsr_string
	movs	r0,#32
	bl	strcat

	movs	r4,#0		@ init Y
yloop:
	movs	r3,#0		@ init X
xloop:
	mul	r0,r3,r5		@ X * frame
	sub	r0,r4,r0, ASR #8	@ Y - (x*frame)/256
	mul	r7,r4,r5		@ Y * frame
	add	r7,r3,r7, ASR #8	@ X + (y*frame)/256
	ands	r0,r0,r7

	ands	r0,#0xf0		@ color

	ite	eq
	moveq	r7,#'2'			@ green if color=0
	movne	r7,#'0'			@ black else

	movw	r1,#:lower16:color_string
	strb	r7,[r1,3]		@ patch string with 2/0

	lsrs	r0,#4
	adds	r0,r0,#' '
	strb	r0,[r1,5]		@ patch output char

	movs	r0,#6			@ length in r0

	cmp	r3,#XWIDTH-1
	bne	skip_lf
	adds	r0,r0,#1		@ tack linefeed on end
skip_lf:

	bl	strcat

	adds	r3,r3,#1			@ decrement X
	cmp	r3,#XWIDTH
	bne	xloop

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r0
write_stdout:
	movs	r0,#STDOUT
	mov	r1,r6
	movs	r7,#SYSCALL_WRITE
	swi	#0

	movs	r2,#0				@ clear strcat count

	adds	r4,r4,#1			@ increment Y
	cmp	r4,#YHEIGHT
	bne	yloop

	adds	r5,r5,#8			@ update frame

	b	forever_loop

	@================================
	@ strcat
	@================================
	@ len in r0
	@ string in r1
strcat:

strcat_loop:
	ldrb	r7,[r1],1		@ load input, then increment r1 after
	strb	r7,[r6,r2]		@ store to out_buffer+r2
	adds	r2,r2,#1
	subs	r0,r0,#1
	bne	strcat_loop
	blx	lr

data_begin:

color_string:
	.ascii	"\033[40m "		@ 0
linefeed:
	.ascii	"\n"			@ 6
dsr_string:
	@ 113/2 = 56
	@ 32 bytes long
	.ascii "\033[52;55H- d e s i r e -\033[1;1H"

out_buffer:
	.ascii "\033[2J"		@ 4 long
