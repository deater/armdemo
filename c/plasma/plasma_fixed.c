#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

char output[65536];

int32_t double_to_fixed(double in) {

	int32_t x=0;

	x=round(in * (1 << 16));

	return x;
}

int32_t fixed_mul(int32_t x, int32_t y) {

	int64_t result,x1,y1;

	x1=x;
	y1=y;

	result=((x1*y1)>>16);

	return result;
}

int32_t our_sin(int32_t x) {

	int32_t result;
	int32_t x3,x5;
	int32_t x3t,x5t;

	// sin(x) ~= x - (x^3)/3!  + (x^5)/5! - (x^7)/7!

	x3=fixed_mul(x,x);
	x3=fixed_mul(x3,x);
	x3t=fixed_mul(x3,double_to_fixed(1.0/6.0));

	x5=fixed_mul(x3,x);
	x5=fixed_mul(x5,x);
	x5t=fixed_mul(x5,double_to_fixed(1.0/120.0));

	result=x-x3t+x5t;

	return result;
}

// cos
//      1    0
//
//
// sin   0   1

// cos=sine shifted left by pi/2

//        0  pi/2  pi
// sin    0   1    0
// cos    1   0
int32_t our_cos(int32_t x) {

	int32_t offset;

	offset=double_to_fixed(1.57);

	return our_sin(offset-x);
}


#if 0

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

#endif

int main(int argc, char **argv) {

	int length;
	int32_t x,y,xx,yy;
	int32_t c,t=0;
	int o;

	char string[1024];

	while(1) {
		strcpy(output,"\x1b[1;1H");

		for(y=0;y<24;y++) {
			for(x=0;x<80;x++) {
				xx=(x<<16)>>7;
				yy=(y<<16)>>7;
				c=our_cos(xx)+ // cos
					our_sin(yy)+t;
				//o=(c*64.0);	// <<5 then >> 16

				o=((c<<5)>>16);

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
		t=t+double_to_fixed(1.0/200.0);

	}
	return 0;
}
