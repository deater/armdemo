CC = gcc
CFLAGS = -O2 -Wall
LFLAGS = -lm

all:	plasma plasma_simple plasma_fixed make_sines

###

plasma:	plasma.o
	$(CC) -o plasma plasma.o $(LFLAGS)

plasma.o:	plasma.c
	$(CC) $(CFLAGS) -c plasma.c

###

plasma_simple:	plasma_simple.o
	$(CC) -o plasma_simple plasma_simple.o $(LFLAGS)

plasma_simple.o:	plasma_simple.c
	$(CC) $(CFLAGS) -c plasma_simple.c

###

plasma_fixed:	plasma_fixed.o
	$(CC) -o plasma_fixed plasma_fixed.o $(LFLAGS)

plasma_fixed.o:	plasma_fixed.c
	$(CC) $(CFLAGS) -c plasma_fixed.c

###

make_sines:	make_sines.o
	$(CC) -o make_sines make_sines.o $(LFLAGS)

make_sines.o:	make_sines.c
	$(CC) $(CFLAGS) -c make_sines.c


###

clean:	
	rm -f *~ *.o plasma plasma_simple plasma_fixed

