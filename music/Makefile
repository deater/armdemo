CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =

all:	test parse player player2

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

player.o:	player.c common.h music_track1.h music_track2.h
	$(CC) $(CFLAGS) -c player.c

###

player2:	player2.o common.o
	$(CC) $(LFLAGS) -o player2 player2.o common.o -lm

player2.o:	player2.c common.h music_track1.h music_track2.h
	$(CC) $(CFLAGS) -c player2.c



###

parse:	parse.o common.o
	$(CC) $(LFLAGS) -o parse parse.o common.o -lm

parse.o:	parse.c common.h
	$(CC) $(CFLAGS) -c parse.c


###

clean:	
	rm -f *~ *.o test parse player player2

