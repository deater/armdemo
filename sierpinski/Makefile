LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
LDFLAGS = -N --thumb-entry=_start
ASFLAGS = -mthumb-interwork

all:	sierpinski_asm sierpinski

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

clean:	
	rm -f *~ *.o sierpinski_asm sierpinski
