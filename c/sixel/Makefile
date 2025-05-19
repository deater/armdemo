CC = gcc
CFLAGS = -O2 -Wall

all:	test_sixel star_path_sixel star_path_sixel_test \
	star_path_sixel_compact palette_test

###

star_path_sixel:	star_path_sixel.o
	$(CC) -o star_path_sixel star_path_sixel.o $(LFLAGS)

star_path_sixel.o:	star_path_sixel.c
	$(CC) $(CFLAGS) -c star_path_sixel.c

###

star_path_sixel_test:	star_path_sixel_test.o
	$(CC) -o star_path_sixel_test star_path_sixel_test.o $(LFLAGS)

star_path_sixel_test.o:	star_path_sixel_test.c
	$(CC) $(CFLAGS) -c star_path_sixel_test.c


###

star_path_sixel_compact:	star_path_sixel_compact.o
	$(CC) -o star_path_sixel_compact star_path_sixel_compact.o $(LFLAGS)

star_path_sixel_compact.o:	star_path_sixel_compact.c
	$(CC) $(CFLAGS) -c star_path_sixel_compact.c

###

test_sixel:	test_sixel.o
	$(CC) -o test_sixel test_sixel.o $(LFLAGS)

test_sixel.o:	test_sixel.c
	$(CC) $(CFLAGS) -c test_sixel.c

###

palette_tet:	palette_tet.o
	$(CC) -o palette_tet palette_tet.o $(LFLAGS)

palette_tet.o:	palette_tet.c
	$(CC) $(CFLAGS) -c palette_tet.c


###

clean:	
	rm -f *~ *.o star_path_sixel sixel test_sixel \
	star_path_sixel_test star_path_pixel_compact palette_test
