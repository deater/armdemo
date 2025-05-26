CC = gcc
CFLAGS = -g -O2 -Wall
LFLAGS = 

all:	plasma_simple rr

###

plasma_simple:	plasma_simple.o
	$(CC) -o plasma_simple plasma_simple.o $(LFLAGS) -lm

plasma_simple.o:	plasma_simple.c
	$(CC) $(CFLAGS) -c plasma_simple.c

###

rr:	rr.o
	$(CC) -o rr rr.o $(LFLAGS)

rr.o:	rr.c
	$(CC) $(CFLAGS) -c rr.c

###

clean:	
	rm -f *~ *.o plasma_simple rr
