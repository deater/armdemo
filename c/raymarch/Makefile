CC = gcc
CFLAGS = -Wall -O2

SDL_LIBS= `sdl-config --libs`
SDL_INCLUDE= `sdl-config --cflags`

all:	raymarch raymarch_small

raymarch:	raymarch.o mode13h.o
	$(CC) -o raymarch raymarch.o mode13h.o $(SDL_LIBS) $(LFLAGS)

raymarch.o:	raymarch.c
	$(CC) $(CFLAGS) -c raymarch.c

###

raymarch_small:	raymarch_small.o mode13h.o
	$(CC) -o raymarch_small raymarch_small.o mode13h.o $(SDL_LIBS) $(LFLAGS)

raymarch_small.o:	raymarch_small.c
	$(CC) $(CFLAGS) -c raymarch_small.c

###

mode13h.o:	mode13h.c
	$(CC) $(CFLAGS) $(SDL_INCLUDE) -c mode13h.c

clean:	
	rm -f *.o *~ raymarch
