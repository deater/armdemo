CC = gcc
CFLAGS = -O2 -Wall
LFLAGS = -lm

plasma:	plasma.o
	$(CC) -o plasma plasma.o $(LFLAGS)

plasma.o:	plasma.c
	$(CC) $(CFLAGS) -c plasma.c

clean:	
	rm -f *~ *.o plasma

