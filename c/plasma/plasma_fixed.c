#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

char output[65536];

#if 0
static int32_t double_to_fixed(double in) {

	int32_t x=0;

	x=round(in * (1 << 16));

	return x;
}
#endif

static int32_t fixed_mul(int32_t x, int32_t y) {

	int64_t result,x1,y1;

	x1=x;
	y1=y;

	result=((x1*y1)>>16);

	return result;
}

static int32_t our_sin(int32_t x) {

	int32_t result;
	int32_t x2,x3,x5;
	int32_t x3t,x5t;


//	if (x>0x3243F) {
//		fprintf(stderr,"%X\n",x);
//	}

	/* This approximation only works from roughly -pi to pi */
	while(x>0x3243F) {		/* 0x3243f = roughly pi */
		x=x-(0x3243F*2);
	}

	// sin(x) ~= x - (x^3)/3!  + (x^5)/5! - (x^7)/7!

	x2=fixed_mul(x,x);
	x3=fixed_mul(x2,x);
	x3t=fixed_mul(x3,0x2AAB);	// double_to_fixed(1.0/6.0));

	x5=fixed_mul(x3,x2);
	x5t=fixed_mul(x5,0x222);	// double_to_fixed(1.0/120.0));

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
static int32_t our_cos(int32_t x) {

	int32_t offset;

	offset=0x19220;	/* pi/2 */

//	offset=double_to_fixed(1.57);

	return our_sin(offset-x);
}

int main(int argc, char **argv) {

	int length;
	int32_t x,y,xx,yy;
	int32_t c,t=0;
	int o;
	int t_direction=0;

	char string[1024];

//	printf("%X\n",double_to_fixed(3.14159265358979));

//	exit(1);

	while(1) {
//		fprintf(stderr,"%d\n",t);

		strcpy(output,"\x1b[1;1H");

		for(y=0;y<24;y++) {
			for(x=0;x<80;x++) {
				xx=x<<9;	// xx=(x<<16)>>7;
						// fixed point
						// x/128
						// so 0..0.625
				yy=y<<9;	// yy=(y<<16)>>7;
						// so 0..0.18
				c=our_cos(xx+t)+ // cos
					our_sin(yy)+t;
				//o=(c*64.0);	// <<5 then >> 16

				o=c>>11;	// o=((c<<5)>>16);

				int cc=c>>8;

				sprintf(string,
					"\x1b[38;2;%d;%d;%dm%c",
					(cc&0x3f)*4,
					((cc+32)&0x3f)*4,
					((cc+48)&0x3f)*4,
					(o&0x3f)+' ');

				strcat(output,string);
			}
			strcat(output,"\n");

		}
		length=strlen(output);
		write(STDOUT_FILENO,output,length);

		usleep(30000);
		//t=t+double_to_fixed(1.0/200.0);
		if (t_direction) {
			t=t+0x148; // (1/200)
		}
		else {
			t=t-0x148; // (1/200)
		}
				// above 5 or so it get stuck and flashes?
		if (t>0x50000) {
			t_direction=!t_direction;
		}

	}
	return 0;
}
