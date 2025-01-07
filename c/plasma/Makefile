CC = gcc
CFLAGS = -O2 -Wall
LFLAGS = -lm

all:	plasma plasma_simple

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

clean:	
	rm -f *~ *.o plasma plasma_simple

