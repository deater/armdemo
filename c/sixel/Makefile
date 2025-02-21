CC = gcc
CFLAGS = -O2 -Wall

all:	test_sixel star_path_sixel

###

star_path_sixel:	star_path_sixel.o
	$(CC) -o star_path_sixel star_path_sixel.o $(LFLAGS)

star_path_sixel.o:	star_path_sixel.c
	$(CC) $(CFLAGS) -c star_path_sixel.c

###

test_sixel:	test_sixel.o
	$(CC) -o test_sixel test_sixel.o $(LFLAGS)

test_sixel.o:	test_sixel.c
	$(CC) $(CFLAGS) -c test_sixel.c


###

clean:	
	rm -f *~ *.o star_path_simple sixel test_sixel
