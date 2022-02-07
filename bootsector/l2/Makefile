CROSS = arm-none-eabi-
CC = gcc
AS = as
AR = ar
RANLIB = ranlib
ASFLAGS = -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard
ASFLAGS_ARM1176 = -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard
ASFLAGS_ARMV7 = -mcpu=cortex-a7 -mfloat-abi=hard
CFLAGS = -O2 -Wall -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard -marm -nostartfiles -ffreestanding -nostdlib
CFLAGS_ARMV7 = -O2 -Wall -Werror -DARMV7=1 -mcpu=cortex-a7 -mfloat-abi=hard -marm -nostartfiles -ffreestanding -nostdlib
CFLAGS_ARM1176 = -O2 -Wall -Werror -DARM1176=1 -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard -marm -nostartfiles -ffreestanding -nostdlib -mgeneral-regs-only
LFLAGS = --no-undefined -T $(LINKER_SCRIPT)

LINKER_SCRIPT = kernel.ld

all:	kernel.img kernel.dis

kernel.img:	kernel.elf
	$(CROSS)objcopy kernel.elf -O binary kernel.img

### ARM1176

kernel.elf:	kernel_main.arm1176.o
	$(CROSS)ld $(LFLAGS) \
		kernel_main.arm1176.o -Map kernel.map -o kernel.elf

kernel_main.arm1176.o:	kernel_main.s pi.inc
	$(CROSS)$(AS) $(ASFLAGS_ARM1176) $(INCLUDE) \
		-o kernel_main.arm1176.o -c kernel_main.s

kernel.dis:	kernel.elf
	$(CROSS)objdump --disassemble-all kernel.elf > kernel.dis

clean:
	rm -f *~ *.o *.map *.elf kernel.img kernel7.img *.dis date.h
