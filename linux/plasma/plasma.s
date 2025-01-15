@ ARM32/Thumb Plasma

XWIDTH	= 	80
YHEIGHT	=	24

.arch armv6

# Syscalls
.equ SYSCALL_EXIT,	1
.equ SYSCALL_WRITE,	4
#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

@ register allocation

        .globl _start
_start:

forever_loop:
	movs	r2,#0				@ clear strcat count


	ldr	r6,=out_buffer

	@ clear screen
	mov	r0,#4
	ldr	r1,=clear_screen
	bl	strcat_loop

	movs	r4,#0				@ set Y to 0
yloop:

	mov	r5,#0				@ set X to 0
xloop:

	mov	r9,#'A'
	strb	r9,[r6,r2]		@ store to out_buffer+r2
	adds	r2,r2,#1

	adds	r5,r5,#1		@ increment X
	cmp	r5,#XWIDTH
	bne	xloop

	mov	r9,#'\n'
	strb	r9,[r6,r2]
	adds	r2,r2,#1

	adds	r4,r4,#1			@ increment Y
	cmp	r4,#YHEIGHT
	bne	yloop


	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	movs	r0,#STDOUT
	mov	r1,r6
	movs	r7,#SYSCALL_WRITE
	swi	#0


	b	forever_loop

	@================================
	@ strcat
	@================================
	@ len in r0
	@ string in r1
strcat:

strcat_loop:
	ldrb	r7,[r1],#1		@ load input, then increment r1 after
	strb	r7,[r6,r2]		@ store to out_buffer+r2
	adds	r2,r2,#1
	subs	r0,r0,#1
	bne	strcat_loop
	bx	lr			@ return

.data

color_string:
	.ascii	"\033[40m "		@ 0
linefeed:
	.ascii	"\n"			@ 6
clear_screen:
	.ascii "\033[2J"		@ 4 long
.bss
.lcomm	out_buffer, 65536
