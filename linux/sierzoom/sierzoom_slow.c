#include <stdio.h>
#include <unistd.h>

#define XSIZE	128
#define	YSIZE	50

int main(int argc, char **argv) {

	int x,y,frame,color;

	frame=-4096;
//	frame=-512;

	while(1) {
		printf("\033[1;1H");
		for(y=0;y<YSIZE;y++) {
			for(x=0;x<XSIZE;x++) {
				color=( (y-((x*frame)/256)) & (x+((y*frame)/256))) &0xf0;

//				color=( (y-((x*frame)/256)) & (x+((y*frame)/256)))>>4;

				if (color) {
					printf("\033[40m");
				}
				else {
					printf("\033[42m");
				}
				putchar(' '+(color>>4));
			}
			printf("\n");
			fflush(stdout);
			fsync(1);
		}
		frame+=8;
//		usleep(30000);
	}

	return 0;
}
