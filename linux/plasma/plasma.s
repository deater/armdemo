@ ARM32/Thumb Plasma

XWIDTH	= 	80
YHEIGHT	=	24

.arch armv6

# Syscalls
.equ SYSCALL_EXIT,	1
.equ SYSCALL_WRITE,	4
.equ SYSCALL_NANOSLEEP,162
#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

@ register allocation
@
@ r0, r1 = arguments
@ r4 = o
@ r5 = c
@ r6 = output pointer
@ r7 = temp
@ r8 = t
@ r9 = x
@ r10 = y
@ r11 = o
@ r12 = c
@ r13 = stack
@ r14 = link register
@ r15 = program counter

        .globl _start
_start:

	mov	r8,#0

plasma_loop:				@ while(1) {
	ldr	r6,=out_buffer
	ldr	r0,=move_to_start	@ strcpy(output,"\x1b[1;1H");
	bl	strcat

	mov	r10,#0			@ for(y=0;y<24;y++) {
yloop:
	mov	r9,#0			@ for(x=0;x<80;x++) {
xloop:
	add	r0,r8,r9,ASL #9		@ xx=(x<<9)+t;	// xx=(x<<16)>>7;
	bl	our_cos			@ c=our_cos(xx)
	mov	r4,r0

	mov	r0,r10,ASL #9		@ yy=y<<9;	// yy=(y<<16)>>7;
	bl	our_sin			@ c=c+ // cos

	add	r12,r0,r4
	add	r12,r12,r8

	@ FIXME shift if by 8 earlier than by 3

					@	our_sin(yy)+t*2;
	mov	r4,r12,LSR #11		@ o=c>>11;	// o=((c<<5)>>16);
	mov	r5,r12,LSR #8		@ cc=c>>8;

@				sprintf(string,
@					"\x1b[38;2;%d;%d;%dm%c",
@					(cc&0x3f)*4,
@					((cc+32)&0x3f)*4,
@					((cc+48)&0x3f)*4,
@					(o&0x3f)+' ');
	and	r1,r4,#0x3f	@	mov	r1,#'A'
	add	r1,r1,#' '
	bl	strcat_char

				@ strcat(output,string);

	add	r9,r9,#1	@ increment x
	cmp	r9,#XWIDTH
	bne	xloop		@ loop

	ldr	r0,=linefeed	@	strcat(output,"\n");
	bl	strcat

	add	r10,r10,#1	@ increment y
	cmp	r10,#YHEIGHT
	bne	yloop		@ loop


	@ length=strlen(output);
	@ write(STDOUT_FILENO,output,length);

	ldr	r1,=out_buffer
	sub	r2,r6,r1

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	movs	r0,#STDOUT
	movs	r7,#SYSCALL_WRITE
	swi	#0

	@=================================
	@ usleep
	@=================================

	@	usleep(30000);

	@ setup pointer to timespec struct

	ldr	r0,=timespec_30k	@ struct timespec
	mov	r1,#0			@ NULL pointer

	movs	r7,#SYSCALL_NANOSLEEP
	swi	#0

	@==========================

	add	r8,r8,#0x148		@	t=t+0x148; // (1/200)


	@==========================

	b	plasma_loop		@	loop forever


	@================================
	@ strcat_char
	@================================
	@ char in r1
strcat_char:
	ldr	r0,=output_char
	strb	r1,[r0]

	@ fallthrough


	@================================
	@ strcat
	@================================
	@ string in r0
strcat:

strcat_loop:
	ldrb	r7,[r0],#1		@ load input, then increment r1 after
	cmp	r7,#0
	beq	strcat_done
	strb	r7,[r6],#1		@ store to out_buffer+r2
	b	strcat_loop
strcat_done:
	bx	lr			@ return


	@=================================
	@ 16.16 fixed point multiply
	@=================================
	@ input r0, r1
	@ output r0
	@ r1 trashed
fixed_mul:
	@	result=((x1*y1)>>16);		@

	smull	r0, r1, r0, r1		@ r0*r1 -> {r1,r0}
	lsr	r0, r0, #16
	orr	r0, r0, r1, lsl #16
	bx	lr


	@==============================
	@ our_cos
	@==============================
	@ input in r0, output in r0
our_cos:
	ldr	r1,=0x19220		@	offset=0x19220;	/* pi/2 */
	sub	r0,r1,r0		@	return our_sin(offset-x);

	@ fallthrough


	@==============================
	@ our_sin
	@==============================
	@ input in r0, output in r0
	@
	@ sin(x) ~= x - (x^3)/3!  + (x^5)/5! - (x^7)/7!

our_sin:
	push	{lr}
	mov	r7,r0			@ save r0 for later

	mov	r0,r0
	mov	r1,r0
	bl	fixed_mul
	mov	r2,r0			@ x2=fixed_mul(x,x);

	mov	r0,r2
	mov	r1,r7
	bl	fixed_mul
	mov	r3,r0			@ x3=fixed_mul(x2,x);

	mov	r0,r3
	mov	r1,r2
	bl	fixed_mul
	mov	r5,r0			@ x5=fixed_mul(x3,x2);

	mov	r0,r3
	ldr	r1,=0x2aab		@ double_to_fixed(1.0/6.0));
	bl	fixed_mul
	mov	r3,r0			@ x3t=fixed_mul(x3,0x2AAB);

	mov	r0,r5
	ldr	r1,=0x222		@ double_to_fixed(1.0/120.0));
	bl	fixed_mul
	mov	r5,r0			@ x5t=fixed_mul(x5,0x222);

	add	r3,r3,r5
	sub	r0,r7,r3		@ result=x-x3t+x5t;

	pop	{lr}
	bx	lr			@ return result;




.data

output_char:
	.byte	0,0

color_string:
	.ascii	"\033[40m "		@ 0
linefeed:
	.ascii	"\n"			@
	.byte 0
move_to_start:
	.ascii "\033[1;1H"		@
	.byte 0
timespec_30k:
	.word	0			@ seconds
	.word	30000000		@ nanoseconds

.bss
.lcomm	out_buffer, 65536
