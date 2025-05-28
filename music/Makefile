CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =

all:	test parse player

###

test:	test.o
	$(CC) $(LFLAGS) -o test test.o -lm

test.o:	test.c
	$(CC) $(CFLAGS) -c test.c

###

common.o:	common.c common.h
	$(CC) $(CFLAGS) -c common.c


###

player:	player.o common.o
	$(CC) $(LFLAGS) -o player player.o common.o -lm

player.o:	player.c common.h music.h
	$(CC) $(CFLAGS) -c player.c


###

parse:	parse.o common.o
	$(CC) $(LFLAGS) -o parse parse.o common.o -lm

parse.o:	parse.c common.h
	$(CC) $(CFLAGS) -c parse.c


###

clean:	
	rm -f *~ *.o test parse player

