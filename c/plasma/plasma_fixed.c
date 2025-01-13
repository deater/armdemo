#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <stdlib.h>

char output[65536];

double cos_table[80],sin_table[24];

int setup_table(void) {

	int x,y;

	for(x=0;x<80;x++) {
		cos_table[x]=cos(x/128.0);
		printf("%d: %.2f\n",x,cos_table[x]);
	}
	for(y=0;y<24;y++) {
		sin_table[y]=sin(y/128.0);
	}

	exit(1);
	return 0;
}

int main(int argc, char **argv) {

	int length;
	int x,y;
	double c,t=0;
	int o;

	char string[1024];

	setup_table();

	while(1) {
		strcpy(output,"\x1b[1;1H");

		for(y=0;y<24;y++) {
			for(x=0;x<80;x++) {
				c=cos_table[x]+sin_table[y]+t;
				o=(c*64.0);

				sprintf(string,
					"\x1b[38;2;%d;%d;%dm%c",
					(o&0x3f)*4,
					((o+32)&0x3f)*4,
					((o+48)&0x3f)*4,
					(o&0x3f)+' ');

				strcat(output,string);
			}
			strcat(output,"\n");

		}
		length=strlen(output);
		write(STDOUT_FILENO,output,length);

		usleep(30000);
		t=t+1.0/200.0;

	}
	return 0;
}
