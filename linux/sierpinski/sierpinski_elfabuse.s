.syntax unified
#.arm
.thumb

@ ELF header

@LOAD_ADDRESS = 0x00010054	@ original load address
@LOAD_OFFSET = 0x54

LOAD_OFFSET = 0x8
LOAD_ADDRESS = 0x00008000+LOAD_OFFSET	@ original load address


@ wastes $54 (84 bytes)

@ $00 magic number
.byte 0x7f,'E','L','F'

@ $04 class (32 bit)
.byte 0x01

@ $05 endianess (little)
.byte 0x01

@ $06 ELF version
.byte 0x01

@ $07 OS ABI (System V)
.byte 0x00

real_start:

@ $08 extended ABI + 7 bytes padding
@     Linux ignores this in statically linked apps?
@.byte 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
	movw	r6,#:lower16:data_begin		@ 4 bytes
	movs	r3,#2				@ 2 bytesm
	b.n	_start				@ 2 bytes
@.byte 0x99,0x99

@ $10 ELF file type (2==executable)
.byte 0x02,0x00

@ $12 target architecture (0x0028 == ARM32)
.byte 0x28,0x00

@ $14 version
.byte 0x01,0x00,0x00,0x00

@ $18 entry point in executable (+1 because we're thumb)
@.byte 0x55,0x00,0x01,0x00
.int LOAD_ADDRESS+1

@ $1C e_phoff -- start of header following this one
.byte 0x34,0x00,0x00,0x00

@ $20 e_shoff -- start of section header table  (not needed as we have none)
@.byte 0x00,0x00,0x00,0x00

.byte 0			@ pad to 8 bytes, also be sure 0 in the string
			@ in right place
data_begin:

color_string:
	.byte 27,'[','4',0,'m',' '
@	.ascii	"\033[40m "
linefeed:
	.ascii	"\n"

@.byte 0xde,0xad,0xbe,0xef

@ $24 e_flags -- flags [Version5 EABI] [soft-float ABI] (ignored by Linux?)
@ No, the very first (high) byte has rules?  0 is OK, but 'm' isn't?
@.byte 0x00,0x02,0x00,0x05
@.byte 0xde,0xad,0xbe,0xef

@ $28 e_ehsize -- Size of this header
.byte 0x34,0x00

@ $2A e_phentsize -- size of program header entry
.byte 0x20,0x00


@ $2C e_phnum -- number of entries in header table
.byte 0x01,0x00

time:
@ $2E e_shentsize -- size of section header entry
.byte 0x00,0x00

@ $30 e_shnum -- number of entries in section header
.byte 0x00,0x00

@ $32 e_shstrndx -- index of section header
.byte 0x00,0x00

@@@@@@@@@@@@@@@@@@@@ END OF ELF HEADER

@@@@@@@@@@@@@@@@@@@@ Program header

@ $00 p_type -- 0x1 == PT_LOAD (loadable segment)
.byte 0x01,0x00,0x00,0x00

@ $04 p_offset -- offset of segment file in image
@.byte 0x54,0x00,0x00,0x00
.byte LOAD_OFFSET,0x00,0x00,0x00

@ $08 p_vaddr -- virtual address of segment in image
.int LOAD_ADDRESS

@ $0c p_paddr -- physical address
.int LOAD_ADDRESS

@ $10 p_filesz -- size of segment
.byte real_end-real_start,0x00,0x00,0x00
@.byte 0x44,0x00,0x00,0x00

@ $14 p_memsz -- size of segment in memory
.byte real_end-real_start,0x00,0x00,0x00
@.byte 0x44,0x00,0x00,0x00

@ $18 p_flags -- segment dependent flags
.byte 0x07,0x00,0x00,0x00

@ $1C p_align -- alignment	(Linux ignores this?)
@.byte 0x04,0x00,0x00,0x00

@@@@@@@@@@@@@@@@@@@@ end of program header

@ Thumb2 sierpinski

@ 187 bytes -- initial implementation
@ 187 bytes -- use iteq 			(saved 2 bytes)
@ 183 bytes -- no exit
@ 179 bytes -- registers are 0 at entry
@ 175 bytes -- only one color string
@ 171 bytes -- get rid of separate linefeed call
@ 163 bytes -- inline write_stdout
@ 159 bytes -- don't need to save around syscall
@ 155 bytes -- use narrow increment
@ 151 bytes -- countdown X, use cbnz, optimize end of line
@ 148 bytes -- init time struct separately
@ 144 bytes -- modify to load at 0x8000 (so addresses fit in 16-bits)
@ 140 bytes -- start overlapping execution into the header
@ 132 bytes -- move strings into header
@ 130 bytes -- re-arrange some more

# Syscalls
.equ SYSCALL_EXIT,	1
.equ SYSCALL_WRITE,	4
.equ SYSCALL_NANOSLEEP,	162
#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

        .globl _start
_start:
@@	movs	r4,#0		@ Y	registers are 0 at entry on Linux
@	movw	r6,#:lower16:data_begin
@@	movt	r6,#:upper16:data_begin		@ moved start so this always 0



	@ setup delay to be 0x200.0000 nanoseconds (roughly 33ms)
@	movs	r3,#2
	strb	r3,[r6,((time-data_begin)+7)]

forever_loop:
	movs	r3,#78		@ X
xloop:

	ands	r5,r3,r4		@ X AND Y = the sierpinski magic

	ite	eq
	moveq	r5,#'5'			@ purple
	movne	r5,#'0'			@ black

	movs	r1,r6			@ put in r1 for write()
@	ldr	r1,=color_string
	strb	r5,[r6,3]		@ patch string with 2/0
	movs	r2,#6			@ length in r2

	cbnz	r3,skip_lf
	adds	r2,r2,#1		@ tack linefeed on end
skip_lf:

	@================================
	@ write stdout
	@================================
	@ string in r1
	@ len in r2
write_stdout:
	movs	r0,#STDOUT
	movs	r7,#SYSCALL_WRITE
	swi	#0

	subs	r3,r3,#1			@ decrement X
@	cmp	r3,#79
	bpl	xloop

	adds	r4,r4,#1			@ increment Y

	@ usleep(30000);

	adds	r0,r6,#(time-data_begin)	@ time pointer in r0
	movs	r1,0				@ NULL
	movs	r7,#SYSCALL_NANOSLEEP
	swi	#0

	b	forever_loop



	@================================
	@ Exit
	@================================
@exit:
@	movs	r0,#5
@	movs	r7,#SYSCALL_EXIT	@ put exit syscall number (1) in r7
@	swi	#0			@ and exit


@time:
@	.byte	0	@ pad out to 8 bytes
@	.word	0,30000000

real_end:
