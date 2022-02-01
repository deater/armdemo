LD = ld
AS = as
CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =
THUMBLFLAGS = --thumb-entry=_start
LDFLAGS = -N --thumb-entry=_start
ASFLAGS = -mthumb-interwork

all:	sierzoom_asm sierzoom sierzoom_slow


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

sierzoom_asm:	sierzoom_asm.o
	$(LD) $(LDFLAGS) -Ttext=0x8054 -o sierzoom_asm sierzoom_asm.o

sierzoom_asm.o:	sierzoom_asm.s
	$(AS) $(ASFLAGS) -o sierzoom_asm.o sierzoom_asm.s

###
sierzoom_tiny:	sierzoom_raw
	objcopy -O binary sierzoom_raw sierzoom_tiny

sierzoom_raw:	sierzoom_raw.o
	$(LD) $(LDFLAGS) -Ttext=0x10000 -o sierzoom_raw sierzoom_raw.o

sierzoom_raw.o:	sierzoom_raw.s
	$(AS) $(ASFLAGS) -o sierzoom_raw.o sierzoom_raw.s


clean:	
	rm -f *~ *.o sierzoom_asm sierzoom_raw sierzoom_tiny sierzoom sierzoom_slow