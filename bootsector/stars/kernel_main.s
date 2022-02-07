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

	@==========================
	@ clear framebuffer to blue

	ldr	r0, =offscreen_framebuffer
	ldr	r2, =640 * 480
	mov	r1,#20
clear_loop:
	strb	r1,[r0,r2]
	subs	r2, r2, #1
	bne	clear_loop



plot_loop:


	@ putpixel
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

	ldr	r0, =offscreen_framebuffer
	mov	r1,#0xff
	strb	r1,[r8,r0]

	@==========================
	@ copy our framebuffer to
	@ the firmware one

	ldr	r0, =fb_struct
	ldr	r0, [r0, #0x20]		@ get address of framebuffer

	ldr	r4, =palette		@ index negative to this?

	ldr	r1, =offscreen_framebuffer
	eor	r2,r2,r2
copy_loop:
	ldrb	r3,[r1,r2]		@ FIXME: auto-update addr mode
	ldr	r3,[r4,r3,asl #2]	@ lookup color in palette
	str	r3,[r0,r2,asl #2]
	add	r2,r2,#1
	cmp	r2, #(640 * 480)
	bne	copy_loop


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
.lcomm	offscreen_framebuffer,640*480*1
