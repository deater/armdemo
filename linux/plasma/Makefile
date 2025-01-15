LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
#LDFLAGS = -N --thumb-entry=_start
#ASFLAGS = -mthumb-interwork
SSTRIP = ../../sstrip/sstrip
LDFLAGS = -N
ASFLAGS =


all:	plasma

###

submit:	plasma.zip

plasma.zip:	plasma_asm.s file_id.diz
	mkdir -p lovebyte2025_plasma_256
	cp plasma_asm ./lovebyte2025_plasma_256
	cp plasma_asm.s ./lovebyte2025_plasma_256
	cp file_id.diz ./lovebyte2025_plasma_256
	cp plasma_720p.mp4 ./lovebyte2025_plasma_256
	cp plasma_arm.jpg ./lovebyte2025_plasma_256
	zip -r plasma.zip lovebyte2025_plasma_256

###

pouet:	plasma_pouet.zip

plasma_pouet.zip:	plasma_asm.s file_id.diz
	mkdir -p lovebyte2025_plasma_256
	cp plasma_asm ./lovebyte2025_plasma_256
	cp plasma_asm.s ./lovebyte2025_plasma_256
	cp file_id.diz ./lovebyte2025_plasma_256
	cp plasma_arm.jpg ./lovebyte2025_plasma_256
	zip -r plasma_pouet.zip lovebyte2025_plasma_256

###


#plasma:	plasma.o
#	$(CC) $(LFLAGS) -o plasma plasma.o

#plasma.o:	plasma.c
#	$(CC) $(CFLAGS) -c plasma.c

###

plasma_slow:	plasma_slow.o
	$(CC) $(LFLAGS) -o plasma_slow plasma_slow.o

plasma_slow.o:	plasma_slow.c
	$(CC) -g -O0 -Wall -c plasma_slow.c



###

plasma:	plasma_elf
	$(SSTRIP) plasma

plasma_elf:	plasma.o
	$(LD) $(LDFLAGS) -o plasma plasma.o
	cp plasma plasma_elf

plasma.o:	plasma.s
	$(AS) $(ASFLAGS) -o plasma.o plasma.s


clean:	
	rm -f *~ *.o plasma plasma_slow
