LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
LDFLAGS = -N --thumb-entry=_start
ASFLAGS = -mthumb-interwork

all:	sierpinski_raw sierpinski_asm sierpinski sierpinski_tiny

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
	$(LD) $(LDFLAGS) -Ttext=0x10000 -o sierpinski_raw sierpinski_raw.o

sierpinski_raw.o:	sierpinski_raw.s
	$(AS) $(ASFLAGS) -o sierpinski_raw.o sierpinski_raw.s


clean:	
	rm -f *~ *.o sierpinski_asm sierpinski_raw sierpinski
