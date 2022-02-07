@ kernel_main

@ bare-metal assembly code
@ for ARM1176 based Raspberry Pi Systems

@ based on vmwOS, also using PiFox as a reference

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
	ldr	r1, =fb_struct		@ point to request struct
	orr	r1, #0x40000000		@ convert to GPU address
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

	eor	r4, r4, r4			@ clear timeout value
mailbox_read_ready_loop:
	@ Timeout
	add	r4, #1
	tst	r4, #0x80000
	mvnne	r1, #1				@ indicate failure
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

	@ TODO: set up cache

	@ TODO: set up sound

	@ setup palette

	ldr	r4, =palette		@ index negative to this?
	eor	r3,r3,r3		@ color
	eor	r2,r2,r2		@ count
pal_setup_loop:
	str	r3,[r4,r2]
	add	r2,r2,#4
	ldr	r1,=#0x010101
	add	r3,r3,r1
	cmp	r2,#256*4
	bne	pal_setup_loop

	ldr	r10,=offscreen_framebuffer1
	ldr	r11,=offscreen_framebuffer2

	mov	r0,r10
	bl	clear_framebuffer

	mov	r0,r11
	bl	clear_framebuffer


plot_loop:


	@ put drop
putpixel:

	@ get random Y
try_again_y:
	bl	random16	@ Y result in r3
	ldr	r9,=511
	and	r3,r3,r9
	cmp	r3,#480
	bge	try_again_y

	mov	r7,#640		@ Y*640
	mul	r8,r3,r7

	@ get random X
try_again_x:
	bl	random16
	ldr	r9,=1023
	and	r3,r3,r9
	cmp	r3,#640
	bge	try_again_x

	add	r8,r8,r3	@ +X

	mov	r0, r10			@ current_framebuffer
	mov	r1,#0xff
	strb	r1,[r0,r8]


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
	ldr	r9,=(640*478)
	add	r9,r1,r9

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
	eormi	r2,r2,#0xff		@ if negative, invert V
	strb	r2,[r7]			@ save

	add	r1,r1,#1
	add	r7,r7,#1
	cmp	r1,r9
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


random16:

	ldr	r4,=random_seed
	ldr	r3,[r4]
	eor	r3,r3,r3,lsl #7
	eor	r3,r3,r3,lsr #9
	eor	r3,r3,r3,lsl #8
	str	r3,[r4]

	blx	lr

random_seed:
	.word	0x7657

	@==========================
	@ clear framebuffer
clear_framebuffer:
	ldr	r2, =640 * 480
	mov	r1,#0
clear_loop:
	strb	r1,[r0,r2]
	subs	r2, r2, #1
	bne	clear_loop

	blx	lr



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
