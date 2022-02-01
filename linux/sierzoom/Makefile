LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
LDFLAGS = -N --thumb-entry=_start
ASFLAGS = -mthumb-interwork
SSTRIP = ../../sstrip/sstrip

all:	sierzoom_asm sierzoom sierzoom_slow

###

submit:	sierzoom.zip

sierzoom.zip:	sierzoom_asm.s file_id.diz
	mkdir -p lovebyte2022_sierzoom_256
	cp sierzoom_asm ./lovebyte2022_sierzoom_256
	cp sierzoom_asm.s ./lovebyte2022_sierzoom_256
	cp file_id.diz ./lovebyte2022_sierzoom_256
	cp sierzoom_720p.mp4 ./lovebyte2022_sierzoom_256
	cp sierzoom_arm.jpg ./lovebyte2022_sierzoom_256
	zip -r sierzoom.zip lovebyte2022_sierzoom_256

###

sierzoom:	sierzoom.o
	$(CC) $(LFLAGS) -o sierzoom sierzoom.o

sierzoom.o:	sierzoom.c
	$(CC) $(CFLAGS) -c sierzoom.c

###

sierzoom_slow:	sierzoom_slow.o
	$(CC) $(LFLAGS) -o sierzoom_slow sierzoom_slow.o

sierzoom_slow.o:	sierzoom_slow.c
	$(CC) -g -O0 -Wall -c sierzoom_slow.c



###

sierzoom_asm:	sierzoom_asm_elf
	$(SSTRIP) sierzoom_asm

sierzoom_asm_elf:	sierzoom_asm.o
	$(LD) $(LDFLAGS) -Ttext=0x8054 -o sierzoom_asm sierzoom_asm.o
	cp sierzoom_asm sierzoom_asm_elf

sierzoom_asm.o:	sierzoom_asm.s
	$(AS) $(ASFLAGS) -o sierzoom_asm.o sierzoom_asm.s


clean:	
	rm -f *~ *.o sierzoom sierzoom_slow
