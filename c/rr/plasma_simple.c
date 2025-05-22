#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>

// 80=7 bits 24=5 bits color=4 bits = 16 bits
// RLE encoded, 20-126 = 106

unsigned char screen[80*24];

char output[65536];

void dump_fb(void) {
	int x,y,c;




	for(y=0;y<22;y++) {
		for(x=0;x<80;x++) {
			c=screen[(y*80)+x];
//			printf("%c[38;2;%d;%d;%dm",27,
//				(c&0x3f)*4,
//				((c+32)&0x3f)*4,
//				((c+48)&0x3f)*4);
			c=(c&0x3f)+' ';
//			printf("%c",c);
		}
		//printf("\n");
	}

}

int main(int argc, char **argv) {

	int length;
	double x,y,c,t=0;
	int o;

	char string[1024];

	while(1) {
		strcpy(output,"\x1b[1;1H");

		for(y=0;y<24;y++) {
			for(x=0;x<80;x++) {
				c=cos(x/128)+sin(y/128)+t;
				o=(c*64.0);
#if 0
				sprintf(string,"%c",(o&0x3f)+' ');
#else
				sprintf(string,
					"\x1b[38;2;%d;%d;%dm%c",
					(o&0x3f)*4,
					((o+32)&0x3f)*4,
					((o+48)&0x3f)*4,
					(o&0x3f)+' ');
//				printf("%s",string);
#endif
//				fprintf(stderr,"size: %d\n",strlen(string));
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
