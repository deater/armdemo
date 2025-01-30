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
@
@ r0, r1 = arguments
@ r6 = output pointer
@ r7 = temp
@ r8 = t
        .globl _start
_start:
	ldr	r6,=out_buffer
	mov	r8,#0

plasma_loop:					@ while(1) {
	ldr	r0,=move_to_start		@ strcpy(output,"\x1b[1;1H");
	bl	strcat

.if 0
		for(y=0;y<24;y++) {
			for(x=0;x<80;x++) {
				xx=x<<9;	// xx=(x<<16)>>7;
				yy=y<<9;	// yy=(y<<16)>>7;
				c=our_cos(xx+t)+ // cos
					our_sin(yy)+t*2;
				//o=(c*64.0);	// <<5 then >> 16

				o=c>>11;	// o=((c<<5)>>16);

				int cc=c>>8;

				sprintf(string,
					"\x1b[38;2;%d;%d;%dm%c",
					(cc&0x3f)*4,
					((cc+32)&0x3f)*4,
					((cc+48)&0x3f)*4,
					(o&0x3f)+' ');

				strcat(output,string);
			}
			strcat(output,"\n");

		}
.endif


.if 0

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

.endif


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

@	usleep(30000);
@	t=t+0x148; // (1/200)

	add	r8,r8,#0x148


	b	plasma_loop

	@================================
	@ strcat
	@================================
	@ string in r0
strcat:

strcat_loop:
	ldrsb	r7,[r0],#1		@ load input, then increment r1 after
	beq	strcat_done
	strb	r7,[r6],#1		@ store to out_buffer+r2
	b	strcat_loop
strcat_done:
	bx	lr			@ return



fixed_mul:
@	result=((x1*y1)>>16);		@



our_cos:
@static int32_t our_cos(int32_t x) {
@
@	int32_t offset;

@	offset=0x19220;	/* pi/2 */

@//	offset=double_to_fixed(1.57);

@	return our_sin(offset-x);



our_sin:
@	int32_t result;
@	int32_t x2,x3,x5;
@	int32_t x3t,x5t;

@	// sin(x) ~= x - (x^3)/3!  + (x^5)/5! - (x^7)/7!

@	x2=fixed_mul(x,x);
@	x3=fixed_mul(x2,x);
@	x3t=fixed_mul(x3,0x2AAB);	// double_to_fixed(1.0/6.0));

@	x5=fixed_mul(x3,x2);
@	x5t=fixed_mul(x5,0x222);	// double_to_fixed(1.0/120.0));

@	result=x-x3t+x5t;

@	return result;




.data

color_string:
	.ascii	"\033[40m "		@ 0
linefeed:
	.ascii	"\n"			@ 6
move_to_start:
	.ascii "\033[1;1H\000"		@ 6

.bss
.lcomm	out_buffer, 65536
