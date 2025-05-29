CC = gcc
CFLAGS = -g -O2 -Wall
LFLAGS = 

all:	plasma_simple rr rr_tiny

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

rr_tiny:	rr_tiny.o
	$(CC) -o rr_tiny rr_tiny.o $(LFLAGS) -lm

rr_tiny.o:	rr_tiny.c
	$(CC) $(CFLAGS) -c rr_tiny.c


###

clean:	
	rm -f *~ *.o plasma_simple rr rr_tiny
