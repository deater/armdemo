@ kernel_main

@ bare-metal assembly code
@ for ARM1176 based Raspberry Pi Systems

.global _start

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

	@ TODO: set up graphics

	@ TODO: set up cache

	@ TODO: set up sound

forever:
	wfe			@ low-power wait forever
	b	forever

