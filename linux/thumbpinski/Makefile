LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
LDFLAGS = -N --thumb-entry=_start
ASFLAGS = -mthumb-interwork
SSTRIP = ../../sstrip/sstrip

LOAD_ADDRESS = 0x8000

all:	sierpinski_raw sierpinski_asm sierpinski \
	sierpinski_elfabuse sierpinski_tiny sierpinski_ea

###

pouet:	thumbpinski_pouet.zip

submit:	thumbpinski.zip

thumbpinski.zip:	sierpinski_elfabuse.s file_id.diz
	mkdir -p lovebyte2022_thumbpinski_128
	cp sierpinski_ea ./lovebyte2022_thumbpinski_128
	cp sierpinski_elfabuse.s ./lovebyte2022_thumbpinski_128
	cp file_id.diz ./lovebyte2022_thumbpinski_128
	cp thumbpinski_720p.mp4 ./lovebyte2022_thumbpinski_128
	cp thumbpinski.jpg ./lovebyte2022_thumbpinski_128
	zip -r thumbpinski.zip lovebyte2022_thumbpinski_128

###

thumbpinski_pouet.zip:	sierpinski_elfabuse.s file_id.diz
	mkdir -p lovebyte2022_thumbpinski_128
	cp sierpinski_ea ./lovebyte2022_thumbpinski_128
	cp sierpinski_elfabuse.s ./lovebyte2022_thumbpinski_128
	cp file_id.diz ./lovebyte2022_thumbpinski_128
	cp thumbpinski.jpg ./lovebyte2022_thumbpinski_128
	zip -r thumbpinski_pouet.zip lovebyte2022_thumbpinski_128


###

sierpinski:	sierpinski.o
	$(CC) $(LFLAGS) -o sierpinski sierpinski.o

sierpinski.o:	sierpinski.c
	$(CC) $(CFLAGS) -c sierpinski.c


###

sierpinski_asm:	sierpinski_asm.o
	$(LD) $(LDFLAGS) -o sierpinski_asm sierpinski_asm.o

sierpinski_asm.o:	sierpinski_asm.s
	$(AS) $(ASFLAGS) -o sierpinski_asm.o sierpinski_asm.s

###

sierpinski_tiny:	sierpinski_raw
	objcopy -O binary sierpinski_raw sierpinski_tiny

sierpinski_raw:	sierpinski_raw.o
	$(LD) $(LDFLAGS) -Ttext=$(LOAD_ADDRESS) -o sierpinski_raw sierpinski_raw.o

sierpinski_raw.o:	sierpinski_raw.s
	$(AS) $(ASFLAGS) -o sierpinski_raw.o sierpinski_raw.s

###

sierpinski_ea:	sierpinski_elfabuse
	objcopy -O binary sierpinski_elfabuse sierpinski_ea

sierpinski_elfabuse:	sierpinski_elfabuse.o
	$(LD) $(LDFLAGS) -Ttext=$(LOAD_ADDRESS) -o sierpinski_elfabuse sierpinski_elfabuse.o

sierpinski_elfabuse.o:	sierpinski_elfabuse.s
	$(AS) $(ASFLAGS) -o sierpinski_elfabuse.o sierpinski_elfabuse.s



###

clean:	
	rm -f *~ *.o sierpinski_asm sierpinski_raw sierpinski \
			sierpinski_elfabuse sierpinski_tiny \
			sierpinski_ea
