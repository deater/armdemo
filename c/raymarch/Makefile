CC = gcc
CFLAGS = -Wall -O2

SDL_LIBS= `sdl-config --libs`
SDL_INCLUDE= `sdl-config --cflags`

all:	raymarch

raymarch:	raymarch.o mode13h.o
	$(CC) -o raymarch raymarch.o mode13h.o $(SDL_LIBS) $(LFLAGS)

raymarch.o:	raymarch.c
	$(CC) $(CFLAGS) -c raymarch.c

mode13h.o:	mode13h.c
	$(CC) $(CFLAGS) $(SDL_INCLUDE) -c mode13h.c

clean:	
	rm -f *.o *~ raymarch
