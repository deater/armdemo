CC = gcc
CFLAGS = -Wall -O2
LFLAGS = 

all:	png2rle

###

fractal_compress:	fractal_compress.o
	$(CC) -o fractal_compress fractal_compress.o $(LFLAGS)

fractal_compress.o:	fractal_compress.c
	$(CC) $(CFLAGS) -c fractal_compress.c

###

png2rle:	png2rle.o rle_common.o loadpng.o
	$(CC) -o png2rle png2rle.o rle_common.o loadpng.o $(LFLAGS) -lpng

png2rle.o:	png2rle.c
	$(CC) $(CFLAGS) -c png2rle.c

rle_common.o:	rle_common.c
	$(CC) $(CFLAGS) -c rle_common.c

loadpng.o:	loadpng.c
	$(CC) $(CFLAGS) -c loadpng.c


###

clean:	
	rm -f *~ *.o fractal_compress png2rle

