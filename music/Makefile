CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =

all:	test

###

test:	test.o
	$(CC) $(LFLAGS) -o test test.o -lm

test.o:	test.c
	$(CC) $(CFLAGS) -c test.c

###

clean:	
	rm -f *~ *.o test

