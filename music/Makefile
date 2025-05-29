CC = gcc
CFLAGS = -Wall -O2 -g
LFLAGS =

all:	test parse parse2 player player2 player_compact player_tiny

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

player.o:	player.c common.h music_track1.h
	$(CC) $(CFLAGS) -c player.c

###

player_compact:	player_compact.o
	$(CC) $(LFLAGS) -o player_compact player_compact.o -lm

player_compact.o:	player_compact.c
	$(CC) $(CFLAGS) -c player_compact.c

###

player_tiny:	player_tiny.o
	$(CC) $(LFLAGS) -o player_tiny player_tiny.o -lm

player_tiny.o:	player_tiny.c
	$(CC) $(CFLAGS) -c player_tiny.c



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

parse2:	parse2.o common.o
	$(CC) $(LFLAGS) -o parse2 parse2.o common.o -lm

parse2.o:	parse2.c common.h
	$(CC) $(CFLAGS) -c parse2.c


###

clean:	
	rm -f *~ *.o test parse player player2 player_compact

