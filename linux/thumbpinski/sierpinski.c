#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {

	int x,y,color;

	y=0;

	while(1) {
		for(x=0;x<79;x++) {
			color=x&y;

			if (color) {
				printf("\033[40m");
			}
			else {
				printf("\033[42m");
			}
			printf(" ");
		}
		printf("\n");
		y++;
		usleep(30000);
	}

	return 0;
}
