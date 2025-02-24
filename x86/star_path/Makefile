LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
SSTRIP = ../../sstrip/sstrip32
LDFLAGS = -N -melf_i386
ASFLAGS = --32

all:	star_path star_path_raw

###

star_path:	star_path_elf
	$(SSTRIP) star_path

star_path_elf:	star_path.o
	$(LD) $(LDFLAGS) -o star_path star_path.o
	cp star_path star_path_elf

star_path.o:	star_path.s
	$(AS) $(ASFLAGS) -o star_path.o star_path.s

###

star_path_raw:	star_path_raw_elf
	$(SSTRIP) star_path_raw

star_path_raw_elf:	star_path_raw.o
	$(LD) $(LDFLAGS) -o star_path_raw star_path_raw.o
	cp star_path_raw star_path_raw_elf

star_path_raw.o:	star_path_raw.s
	$(AS) $(ASFLAGS) -o star_path_raw.o star_path_raw.s

###


clean:	
	rm -f *~ *.o \
		star_path star_path_elf \
		star_path_raw star_path_raw_elf
