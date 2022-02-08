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

@ Register allocations
@ R0 =	temp			R8=
@ R1 =	temp			R9=  palette?
@ R2 =	temp			R10= framebuffer1
@ R3 =	temp			R11= framebuffer2
@ R4 =	temp			R12= fb_struct?
@ R5 =	free			R13= Stack
@ R6 =	free			R14= Link Register
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
@	ldr	r1, =fb_struct		@ point to request struct
@	orr	r1, #0x40000000		@ convert to GPU address
	ldr	r1, =(fb_struct+0x40000000)
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

	ldr	r9,=palette
	add	r10,r9,#256*4			@ setup framebuffer 1
	add	r11,r10,#(640*480)		@ setup framebuffer 2

	@=================
	@ setup palette
setup_palette:
	eor	r3,r3,r3		@ color
	eor	r2,r2,r2		@ count
pal_setup_loop:
	str	r3,[r9,r2]
	add	r2,r2,#4
	ldr	r1,=#0x010101
	add	r3,r3,r1
	cmp	r2,#256*4
	bne	pal_setup_loop

	@========================
	@ clear both framebuffers

	mov	r0,r10
	blx	clear_framebuffer

	mov	r0,r11
	blx	clear_framebuffer


	@======================
	@ main loop
	@======================

plot_loop:

	@========================
	@ put drop

	@ get random Y (<480)
try_again_y:
	mov	r0,#512		@ will decrement
	mov	r1,#480
	bl	random16	@ Y result in r3

@	and	r3,r3,r5
@	cmp	r3,#480
@	bge	try_again_y

	mov	r7,#640		@ Y*640
	mul	r8,r3,r7

	@ get random X (<640)
try_again_x:
	mov	r0,#1024
	mov	r1,#640
	bl	random16	@ get random number <640
@	ldr	r5,=1023
@	and	r3,r3,r5
@	cmp	r3,#640
@	bge	try_again_x

	add	r8,r8,r3	@ +X

	mov	r1,#0xff		@ put white pixel
	strb	r1,[r10,r8]		@ current_framebuffer+(640*y)+x


	@==========================
	@ for each pixel
	@         C
	@       A V B
	@         D
	@
	@ calculate color as NEW_V = (A+B+C+D)/2 - OLD_V
	@		if NEW_V<0 V=-V

	mov	r1, r10			@ current_framebuffer
	add	r1,r1,#640
	ldr	r5,=(640*478)
	add	r5,r1,r5

	mov	r7, r11			@ output_framebuffer
	add	r7,r7,#640

drop_loop:
	ldrb	r2,[r1,#-1]		@ load A
	ldrb	r3,[r1,#+1]		@ load B
	add	r2,r2,r3		@ r2=A+B
	ldrb	r3,[r1,#+640]		@ load D
	add	r2,r2,r3		@ r2=A+B+D
	ldrb	r3,[r1,#-640]		@ load C
	add	r2,r2,r3		@ r2=A+B+C+D
	lsr	r2,r2,#1		@ r2=(A+B+C+D)/2

	ldrb	r3,[r7]			@ load OLD_V
	subs	r2,r2,r3		@ r2=(A+B+C+D)/2 - OLD_V
@	rsb	r2,r3,r2,lsr #1		@ r2=(A+B+C+D)/2 - OLD_V
	eormi	r2,r2,#0xff		@ if negative, invert V
@	strb	r2,[r7],#1		@ save, increment r7
	strb	r2,[r7]			@ save, increment r7


	add	r1,r1,#1
	add	r7,r7,#1
	cmp	r1,r5
	blt	drop_loop

	@==========================
	@ copy our framebuffer to
	@ the firmware one

	ldr	r0, =fb_struct
	ldr	r0, [r0, #0x20]		@ get address of framebuffer

	ldr	r4, =palette		@ index negative to this?

	mov	r1, r10
	eor	r2,r2,r2
copy_loop:
	ldrb	r3,[r1,r2]		@ FIXME: auto-update addr mode
	ldr	r3,[r4,r3,asl #2]	@ lookup color in palette
	str	r3,[r0,r2,asl #2]
	add	r2,r2,#1
	cmp	r2, #(640 * 480)
	bne	copy_loop

	@ swap r10 and r11
	mov	r0,r10
	mov	r10,r11
	mov	r11,r0

	b	plot_loop

	@============================
	@ random16 (with limits)
	@============================
	@ using linear feedback shift register of sorts?
	@	r0=mask+1
	@	r1=max
	@
	@ r3=result, r4 trashed
random16:
	sub	r0,r0,#1
	ldr	r4,=random_seed
	ldr	r3,[r4]
	eor	r3,r3,r3,lsl #7
	eor	r3,r3,r3,lsr #9
	eor	r3,r3,r3,lsl #8
	str	r3,[r4]

	and	r3,r3,r0
	cmp	r3,r1
	bge	random16

	blx	lr

random_seed:				@ FIXME: can be arbitary value
	.word	0x7657			@ so can just grab some init code?

.thumb
	@==========================
	@ clear framebuffer
clear_framebuffer:
	ldr	r2, =640 * 480
	mov	r1,#0
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
