@ ARM Miasma -- ARM32/Thumb Plasma

@ o/~ The sun is a miasma of incandescent plasma o/~ -- TMBG

@ For ARMv6 Pi1 systems (no Thumb2, no divide instruction)

@ by Vince `deater` Weaver <vince@deater.net>

@ Note: doesn't look like we could use THUMB for anything useful

@ Things that might break someday
@	+ We assume bss follows right after data and we can write from
@		one into the other
@	+ The "-N" option to ld gives this warning
@		ld: warning: plasma has a LOAD segment with RWX permissions

@ See if you notice the discontinuity due to us only using 3 terms
@	in the sine taylor series

@ plain C version, stripped, 5568 bytes
@ 647 bytes -- original working arm32 assembly code
@ 643 bytes -- return with pop {pc}
@ 635 bytes -- optimize uses of pi with shifts and reverse-subtract
@ 610 bytes -- print ; and do masking in strcat_num
@ 582 bytes -- optimize sine routine
@ 574 bytes -- inline fixed_multiply
@ 568 bytes -- use strcat_char for linefeed
@ 562 bytes -- put zero data into bss
@ 557 bytes -- use r12 for bss pointer
@ 555 bytes -- use r12 for data pointer instead
@ 551 bytes -- use ldm to load some constants
@ 543 bytes -- ill-advised hacking up of strcat_num to print direct in string
@ 539 bytes -- optimize strcat
@ 527 bytes -- keep the clear chars in data seg and write off the end into bss
@ 519 bytes -- inline stcat as we're down to one callsite
@ 518 bytes -- remove extraneous 0 in data
@ 510 bytes -- have loops run backward

@ TODO: put data in ELF header?

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
@ r3 = direction
@ r4 = o
@ r5 = c
@ r6 = output pointer
@ r7 = temp
@ r8 = t
@ r9 = x
@ r10 = y
@ r11 = pi
@ r12 = data_pointer
@ r13 = stack
@ r14 = link register
@ r15 = program counter

        .globl _start
_start:
	mov	r3,#0			@ direction
	mov	r8,#0			@ init t (time counter)
@	ldm	r12,{r8,r11}		@ zero, pi

	ldr	r12,=data_begin			@ setup pointer to data seg
	ldr	r11,[r12,#(pi-data_begin)]	@ load pi
		@ FIXME: load and overwrite

plasma_loop:				@ while(1) {

	@===============================
	@ reset r6 to the output_buffer

	add	r6,r12,#(real_start-data_begin)

	@===============================
	@ y loop

@	mov	r10,#0			@ for(y=0;y<24;y++) {
	mov	r10,#(YHEIGHT-1)
yloop:

	@===============================
	@ x loop

@	mov	r9,#0			@ for(x=0;x<80;x++) {
	mov	r9,#(XWIDTH-1)
xloop:
	add	r0,r8,r9,ASL #9		@ xx=(x<<9)+t;	// xx=(x<<16)>>7;
	bl	our_cos			@ c=our_cos(xx+t)
	mov	r7,r0			@ save result in r7

	mov	r0,r10,ASL #9		@ yy=y<<9;	// yy=(y<<16)>>7;
	bl	our_sin			@ c=c+sin(yy)

	add	r7,r0,r7		@ c=t+cos+sin
	add	r7,r7,r8

	mov	r5,r7,LSR #8		@ cc=c>>8;	// cc=(c>>8)
	mov	r4,r7,LSR #11		@ o=c>>11;	// o=((c<<5)>>16);

	add	r7,r12,#((r_string+2)-data_begin)

					@ print ';'
	bl	strcat_num		@ print red: cc in r5; (cc&0x3f)*4

	add	r5,r5,#32		@ print ';'
	bl	strcat_num		@ print green: ((cc+32)&0x3f)*4,

	add	r5,r5,#16		@ print ';'
	bl	strcat_num		@ print blue: ((cc+48)&0x3f)*4,

	and	r1,r4,#0x3f		@ (o&0x3f)+' ');
	add	r1,r1,#' '		@ print the character
	strb	r1,[r7,#-2]		@ store and adjust output pointer
					@ -2 so the +5 that happens later
					@ goes to right place

	@======================================================
	@ point to our constructed string with colors to strcat

	add	r0,r12,#(color_string-data_begin)
	@bl	strcat

	@================================
	@ strcat
	@================================
	@ r0: nul-terminated string in r0
	@ r6: output pointer
	@ r7: trashed
strcat:

strcat_loop:
	ldrb	r7,[r0],#1		@ load input, then increment r1 after
	cmp	r7,#0
	strneb	r7,[r6],#1		@ store to out_buffer, increment
	bne	strcat_loop
strcat_done:
@	bx	lr			@ return


	@==========================================

@	add	r9,r9,#1	@ increment x
@	cmp	r9,#XWIDTH
@	bne	xloop		@ loop

	subs	r9,r9,#1
	bpl	xloop

	@==========================================

	mov	r1,#'\n'	@ strcat(output,"\n");
	strb	r1,[r6],#1	@ store to out_buffer, increment

@	add	r10,r10,#1	@ increment y
@	cmp	r10,#YHEIGHT
@	bne	yloop		@ loop

	subs	r10,r10,#1
	bpl	yloop

	@===========================================
	@ setup pointer and length for write()

	add	r1,r12,#(move_to_start-data_begin)
	sub	r2,r6,r1		@ calculate length, put in r2

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
	@ nanosleep
	@=================================

	@	usleep(30000);

	@ setup pointer to timespec struct

	add	r0,r12,#(timespec_30k-data_begin)
	mov	r1,#0			@ NULL pointer

	movs	r7,#SYSCALL_NANOSLEEP
	swi	#0

	@==========================
	@ inc/dec the 't' variable

	cmp	r3,#0
	addeq	r8,r8,#0x148		@	t=t+0x148; // (1/200)
	subne	r8,r8,#0x148		@	t=t+0x148; // (1/200)

	@ if t gets too big then flip direction

	cmp	r8,#0x50000
	eorgt	r3,r3,#1

	@==========================

	b	plasma_loop		@	loop forever





	@==============================
	@ our_cos
	@==============================
	@ input in r0, output in r0
our_cos:

	rsb	r0,r0,r11,LSR #1	@	reverse subtract, r11>>1 = pi/2
					@	return our_sin((pi/2)-x);
	@ fallthrough


	@==============================
	@ our_sin
	@==============================
	@ input in r0, output in r0
	@
	@ sin(x) ~= x - (x^3)/3!  + (x^5)/5! - (x^7)/7!

our_sin:
	push	{r1,r2,r3,r5,lr}

	@ this approximation only really good -pi to pi
	@	so bring back if out of bounds

sine_trunc:
	cmp	r0,r11			@ if > pi
	subgt	r0,r0,r11,lsl #1	@ sub pi*2
	bgt	sine_trunc
done_trunc:

	@ want:
	@ 	x in r0		x*x = 16.16     ?.16,16.? *x -> 16.16
	@	x^3 in r3		is there a 64x32 instruction?
	@	x^5 in r5

	smull	r2, r1, r0, r0		@ (dl,dh)=m*n: r0*r0 -> {r2,r1}
	lsr	r2, r2, #16		@ adjust for 16.16 fixed point
	orr	r2, r2, r1, lsl #16	@ r2=fixed_mul(x*x);   (x^2)

	smull	r3, r1, r2, r0		@ (dl,dh)=m*n: r2*r0 -> {r3,r1}
	lsr	r3, r3, #16		@ adjust for 16.16 fixed point
	orr	r3, r3, r1, lsl #16	@ r3=fixed_mul(x^2,x); (x^3)

	smull	r5, r1, r3, r2		@ (dl,dh)=m*n: r3*r2 -> {r5,r1}
	lsr	r5, r5, #16		@ adjust for 16.16 fixed point
	orr	r5, r5, r1, lsl #16	@ x5=fixed_mul(x3,x2); (x^5)

	ldr	r1,=0x222		@ double_to_fixed(1.0/120.0));
	smull	r5, r1, r5, r1		@ (dl,dh)=m*n: r5*r1 -> {r5,r1}
	lsr	r5, r5, #16		@ adjust for 16.16 fixed point
	orr	r5, r5, r1, lsl #16	@ x5t=fixed_mul(x5,0x222); (x^5/5!)

	ldr	r1,=0x2aab		@ double_to_fixed(1.0/6.0));
	smull	r3, r1, r3, r1		@ (dl,dh)=m*n: r3*r1 -> {r3,r1}
	lsr	r3, r3, #16		@ adjust for 16.16 fixed point
	orr	r3, r3, r1, lsl #16	@ x3t=fixed_mul(x3,0x2AAB); (x^3/3!)

	sub	r0,r0,r3		@ result=x-x3t+x5t;
	add	r0,r0,r5

	pop	{r1,r2,r3,r5,pc}	@ and return


	@#############################
	@ strcat_num
	@#############################
	@ r5 = value to print
	@ r7 = address

strcat_num:

	push	{r2,r3,r4,r5,r8,r9,r10,r11,r12,LR}	@ store return address on stack

	@==================================================
	@ we take result, mask to 0..63, then multiply by 4
	@	so closer to 256

	and	r1,r5,#0x3f		@ mask off
	mov	r1,r1,LSL #2		@ multiply by 4 (adjust color)

div_by_10:
	@================================================================
	@ Divide by 10 - because ARMv6 has no hardware divide instruction
	@    the algorithm multiplies by 1/10 * 2^32
	@    then divides by 2^32 (by ignoring the low 32-bits of result)
        @================================================================
	@ r1=numerator
	@ r9=quotient    r8=remainder
	@ r5=trashed

	@ always go 3 digits

	mov	r10,#3

divide_by_10:
	ldr	r4,=429496730			@ 1/10 * 2^32
	sub	r5,r1,r1,lsr #30		@ adjust
	umull	r8,r9,r4,r5			@ {r8,r9}=r4*r5

	mov	r4,#10				@ calculate remainder

						@ could use "mls" on
						@ thumb2? armv6/armv7
	mul	r8,r9,r4
	sub	r8,r1,r8

	@ r9=Q, R8=R

	add	r8,r8,#0x30	@ convert to ascii
	strb	r8,[r7],#-1	@ store a byte, decrement pointer
	mov	r1,r9		@ move Q in for next divide
	subs	r10,r10,#1
	bne	divide_by_10	@ if Q not zero, loop

	@ ;000;000;000
write_out:
	add	r7,r7,#7	@ adjust pointer

	pop	{r2,r3,r4,r5,r8,r9,r10,r11,r12,PC}	@ restore and return

.data
data_begin:

pi:
	.word	0x3243F		@ pi, goes in r11

color_string:
	.ascii	"\033[38;2;"		@ 0
r_string:
	.ascii	"000;"
g_string:
	.ascii	"000;"
b_string:
	.ascii	"000m"
char:
	.byte	0			@ spot for the output char
@	.byte	0			@ NUL terminator

timespec_30k:
	.word	0			@ seconds
	.word	30000000		@ nanoseconds

move_to_start:
	.ascii "\033[1;1H"		@
real_start:


.bss
bss_begin:
.lcomm	out_buffer, 65536

