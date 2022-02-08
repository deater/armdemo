@ drops

@ by Vince `deater` Weaver, dSr

@ bare-metal assembly code
@ for ARM1176 based Raspberry Pi Systems

@ ARM32+Thumb (Thumb2 not available until pi2 models)

@ based on vmwOS, also using PiFox as a reference

@ Optimization
@ 544 bytes -- initial sorta working
@ 532 bytes -- combine some operations
@ 520 bytes -- make clear framebuffer THUMB
@ 512 bytes -- init pointers with adds rather than =
@ 504 bytes -- optimize random number gen
@ 488 bytes -- more optimization of main loop
@ 476 bytes -- put 640*480 in a reg and use it
@ 456 bytes -- reusing the fb_struct 640 as the random number seed
@ 468 bytes -- blue palette
@ 612 bytes -- add doom fire
@ 596 bytes -- optimize palette gen

@ Register allocations
@ R0 =	temp			R8=  640*480
@ R1 =	temp			R9=  palette
@ R2 =	temp			R10= framebuffer1
@ R3 =	temp			R11= framebuffer2
@ R4 =	temp			R12= fb_struct/random_seed
@ R5 =	free			R13= Stack
@ R6 =	frame			R14= Link Register
@ R7 =				R15= PC



.global _start

.include "pi.inc"

.section .text

@================================
@ kernel entry
@================================
@ Note at entry:
@	r0 = boot method (usually 0 on pi)
@	r1 = hardware type (usually 0xc42 on pi)
@	r2 = start of hardware info device tree on modern firmware
@		on older systems was ATAGS ARM tag boot info (usually 0x100)

_start:
kernel:

	@ set up stack to be right before our entry point (it grows down)
	@ TODO: we might need to set all the alternate stacks too

	mov	sp, #0x8000

	@ TODO: set up interrupt vector table?

	@====================
	@ set up graphics
	@====================

	@ request a framebuffer config from the firmware
	@ using the mailbox interface

	@ this way of allocating the mailbox has been
	@ deprecated in newer firmwares

	ldr	r0, =0x1		@ firmware channel
	ldr	r12, =fb_struct		@ point to request struct
	orr	r1, r12,#0x40000000		@ convert to GPU address
@	ldr	r1, =(fb_struct+0x40000000)
					@ FIXME: combine these to one load?

	@==================
	@ mailbox write
	@==================
mailbox_write:
	ldr	r2, =MAILBOX_BASE
	eor	r4, r4			@ clear timeout

	@ Wait until mailbox is ready
mailbox_write_ready_loop:		@ timeout if mailbox never is ready
	add	r4, #1
	tst	r4, #0x80000
	bne	mailbox_write_done

	@ Flush cache
	mcr	p15, #0, r3, c7, c14, #0	@ flush L1 Dcache

	@ check if status marked as full

	ldr	r3, [r2, #OFFSET_MAILBOX_STATUS]
	tst	r3, #MAILBOX_FULL
	bne	mailbox_write_ready_loop

	@ Send message
	mcr	p15, #0, r3, c7, c10, #5	@ DMB (data memory barrier)
	orr	r1, r0, r1			@ put channel in address
	str	r1, [r2, #OFFSET_MAILBOX_WRITE]	@ write to mailbox

mailbox_write_done:

	@==================
	@ mailbox read
	@==================

mailbox_read:
	ldr	r2, =MAILBOX_BASE

@	eor	r4, r4, r4			@ clear timeout value
						@ let's just assume
						@ it didn't timeout last time
mailbox_read_ready_loop:
	@ Timeout
	add	r4, #1
	tst	r4, #0x80000
@	mvnne	r1, #1				@ indicate failure
	bne	mailbox_read_done

	@ Flush cache
	mcr	p15, #0, r1, c7, c14, #0	@ flush L1 dcache

	@ Check for ready flag
	ldr	r3, [r2, #OFFSET_MAILBOX_STATUS]
	tst	r3, #MAILBOX_EMPTY
	bne	mailbox_read_ready_loop

	@ Read in data
	mcr	p15, #0, r1, c7, c10, #5	@ DMB (data memory barrier)
	ldr	r3, [r2, #OFFSET_MAILBOX_READ]

	@ Check if the channel is right
	and	r1, r3, #0x0F
	teq	r0, r1
	bne	mailbox_read_ready_loop		@ if not, try again

	@ Extract data
	bic       r1, r3, #0xF			@ clear out channel bits
mailbox_read_done:

	@=======================
	@ Setup L1 Dcache
setup_dcache:
@	mov	r0, #0
@	mcr	p15, 0, r0, c7, c7, 0		@ Invalidate caches
@	mcr	p15, 0, r0, c8, c7, 0		@ Invalidate TLB
@	mrc	p15, 0, r0, c1, c0, 0
@	ldr	r1, =0x1004
@	orr	r0, r0, r1			@ Set L1 enable bit
@	mcr	p15, 0, r0, c1, c0, 0

	@ TODO: set up sound



	@=========================================
	@=========================================
	@=========================================
	@ main program
	@=========================================
	@=========================================
	@=========================================
main_program:
	@ init memory pointers

	mov	r6,#64				@ frame count
	mov	r8,#640*480
	ldr	r9,=palette
	add	r10,r9,#256*4			@ setup framebuffer 1
	add	r11,r10,#(640*480)		@ setup framebuffer 2


	@=================
	@ setup palette
	@=================

	@ setup blues
setup_palette:
	eor	r2,r2,r2		@ count
	mov	r3,#0x80		@ color
pal_setup_loop:
	cmp	r2,#56
	movlt	r5,#0x08		@ add when <16
	movge	r5,#0x200		@ add when >16
	str	r3,[r9,r2]		@ store to palette
	add	r3,r3,r5		@ inc color
	add	r2,r2,#4		@ inc pointer
	cmp	r2,#256*4		@ see if done
	bne	pal_setup_loop		@ loop

@	ldr	r9,=devel_pal

	@========================
	@ clear both framebuffers

	mov	r0,r10
	blx	clear_framebuffer

	mov	r0,r11
	blx	clear_framebuffer


	@======================
	@ main loop
	@======================

	@ for fire, draw horizontal line at bottom, color 31
	@ draw line

	mov	r2,#0x1f			@ load color
	add	r1,r8,#-640			@ r1 is offset
hline_loop:
	strb	r2,[r11,r1]			@ store the byte
	add	r1,r1,#1			@ increment
	cmp	r1,r8				@ see if reached end (640*480)
	bne	hline_loop			@ loop if not

plot_loop:

	@ check frame count
	subs	r6,r6,#1
	bmi	doom_rain

	@ doom fire
doom_fire:
	mov	r5,#480
	sub	r5,r5,#1

	@ for(y=firetop;y<479;y++) {
	mov	r4,#200
fire_yloop:

	@ for(x=0;x<640;x++) {
	mov	r2,#0
fire_xloop:

	@ r=rand()&7;
	mov	r0,#8		@ will decrement
	mov	r1,#8
	bl	random16	@ r result in r3

	@ dst=(y*XSIZE)+x-(r&3)+1;
	mov	r0,#640
	mul	r0,r4,r0	@ (y*xsize)	mla?
	add	r0,r0,r2	@ (y*xsize)+x
	and	r1,r3,#3	@ r&3
	sub	r7,r0,r1	@ r7=dst
	add	r7,r7,#1	@ (r&3)+1


	@ newcol=buffer[((y+1)*XSIZE)+x]-(r<2);
	mov	r0,#640
	add	r1,r4,#1
	mul	r0,r1,r0	@ (y+1)*XSIZE
	add	r0,r0,r2	@ (y+1)*XSIZE+x
	ldrb	r0,[r11,r0]	@ load value
	cmp	r3,#2
	submi	r0,r0,#1
	@ if (newcol<0) newcol=0;
	cmp	r0,#0
	movmi	r0,#0

	@ buffer[dst]=newcol;
	strb	r0,[r11,r7]

	lsl	r0,#2		@ multiply by 4 for better color
	strb	r0,[r10,r7]

	add	r2,r2,#1
	cmp	r2,#640
	bne	fire_xloop

	add	r4,r4,#1
	cmp	r4,r5
	bne	fire_yloop

	b	copy_framebuffer


	@========================
	@ put drop
doom_rain:

	@ swap r10 and r11
	mov	r0,r10
	mov	r10,r11
	mov	r11,r0

	@ get random Y (<480)

	mov	r0,#512		@ will decrement
	mov	r1,#480
	bl	random16	@ Y result in r3

	mov	r7,#640		@ Y*640
	mul	r5,r3,r7

	@ get random X (<640)

	mov	r0,#1024
	mov	r1,#640
	bl	random16	@ get random number <640

	add	r5,r5,r3	@ +X

	mov	r1,#0xff	@ put white pixel
	strb	r1,[r10,r5]	@ current_framebuffer+(640*y)+x


	@==========================
	@ for each pixel
	@         C
	@       A V B
	@         D
	@
	@ calculate color as NEW_V = (A+B+C+D)/2 - OLD_V
	@		if NEW_V<0 V=-V

	add	r1,r10,#640		@ r1=point to current framebuffer
	add	r5,r10,r8		@ point r5 to end
	add	r5,r5,#-640		@ r5=ending location (1 line from end)

	add	r7,r11,#640		@ r7=point to output framebuffer

drop_loop:
	ldrb	r2,[r1,#-1]		@ load A
	ldrb	r3,[r1,#+1]		@ load B
	add	r2,r2,r3		@ r2=A+B
	ldrb	r3,[r1,#+640]		@ load D
	add	r2,r2,r3		@ r2=A+B+D
	ldrb	r3,[r1,#-640]		@ load C
	add	r2,r2,r3		@ r2=A+B+C+D

	ldrb	r3,[r7]			@ load OLD_V
	rsbs	r2,r3,r2,lsr #1		@ r2=(A+B+C+D)/2 - OLD_V
	eormi	r2,r2,#0xff		@ if negative, invert V
	strb	r2,[r7],#1		@ save, increment r7

	add	r1,r1,#1
	cmp	r1,r5
	blt	drop_loop

	@==========================
	@==========================
	@ copy our framebuffer to
	@ the firmware one, use palette
	@==========================
	@==========================
copy_framebuffer:
	ldr	r0, [r12, #0x20]	@ get address of GPU framebuffer

	mov	r2,r8			@ backwards from end
					@ (r8=640*480)
					@ NOTE: we read/write one word past
					@ end of framebuffer to save 4 bytes
					@ is that OK?
copy_loop:
	ldrb	r3,[r10,r2]		@ read from current framebuffer
	ldr	r3,[r9,r3,asl #2]	@ lookup color in palette
	str	r3,[r0,r2,asl #2]	@ store to GPU
	subs	r2,r2,#1		@ work backwards
	bpl	copy_loop



	b	plot_loop

	@============================
	@ random16 (with limits)
	@============================
	@ using linear feedback shift register of sorts?
	@	r0=mask+1
	@	r1=max
	@
	@ r3=result
random16:
	sub	r0,r0,#1
	ldr	r3,[r12]		@ load random seed
	eor	r3,r3,r3,lsl #7
	eor	r3,r3,r3,lsr #9
	eor	r3,r3,r3,lsl #8
	str	r3,[r12]		@ store out to random seed

	and	r3,r3,r0
	cmp	r3,r1
	bge	random16

	blx	lr

@random_seed:				@ FIXME: can be arbitary value
@	.word	0x7657			@ so can just grab some init code?

.thumb
	@==========================
	@ clear framebuffer
clear_framebuffer:
	mov	r2,r8			@ 640*480
	mov	r1,#0			@ clear to zero
clear_loop:
	strb	r1,[r0,r2]
	sub	r2, #1		@ in thumb mode, S is assumed?
	bne	clear_loop

	blx	lr
.arm


@==============================
@ Framebuffer request structure
@==============================

.align 4				@ must be aligned with bottom 4 bits 0
fb_struct:
random_seed:
 	.int 640	@ 0x00: Physical width
	.int 480	@ 0x04: Physical height
	.int 640	@ 0x08: Virtual width
	.int 480	@ 0x0C: Virtual height
	.int 0		@ 0x10: Pitch
	.int 32		@ 0x14: Bit depth
	.int 0		@ 0x18: X
	.int 0		@ 0x1C: Y
	.int 0		@ 0x20: Address
	.int 0		@ 0x24: Size
.align 2

.section bss
.lcomm	palette,256*4
.lcomm	offscreen_framebuffer1,640*480*1
.lcomm	offscreen_framebuffer2,640*480*1
