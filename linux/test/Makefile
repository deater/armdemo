LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
LDFLAGS = -N --thumb-entry=_start
ASFLAGS = -mthumb-interwork

all:	test_thumb2

###

test_thumb2:	test_thumb2.o
	$(LD) $(LDFLAGS) -o test_thumb2 test_thumb2.o

test_thumb2.o:	test_thumb2.s
	$(AS) $(ASFLAGS) -o test_thumb2.o test_thumb2.s

clean:	
	rm -f *~ *.o test_thumb2
