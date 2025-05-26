#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int colors[]={
	0x909090,0xac783c,0xd0805c,0xe09470,
	0x644818,0x442800,0x985c28,0xd07070,
	0xe08888,0xeca0a0,0x846830,0xb03c3c,
	0xc05858,0xc8c8c8,0x404040,0x2c3000
	};

#include "graphics/rr3_even.h"
#include "graphics/rr3_odd.h"
#include "graphics/rr4_even.h"
#include "graphics/rr4_odd.h"
#include "graphics/rr5_even.h"
#include "graphics/rr5_odd.h"
#include "graphics/rr6_even.h"
#include "graphics/rr6_odd.h"

//unsigned char rr5[]="ZxZxZxZxZxZ`KLZxZB]<^<ZxZ@NONONZxZ>^<_<NZxZ>P^@ZxZ>Na<R"
//	"NZxZ>NQb<NZxZ>MQRSNZxZ>PTQTNZxZ<RPLRLQZxZ<UP"
//	"QRSQZxZ<a<VQRQZxZ>a<b<QZxZ>QVQRZxZ@TQb<ZxZ@a<RZxZB"
//	"PNQZxZBa<RZxZBa<RWXZxZ>a>Wh<ZV~";

/* xxxxxx */
/* 1XCCCC RRRRRR -- color, run */
/* 00CCCC -- color, run = 1 */
/* 01CCCC -- color, run = 2 */
/* 0x3A (:) through 0x7A (z), ~ is terminator */

#define OFFSET ':'

static int debug=0;

static int decode(int c, int r) {
	int i;

	printf("\x1b[48;2;%d;%d;%dm",
			(colors[c]>>16)&0xff,
			(colors[c]>>8)&0xff,
			(colors[c]>>0)&0xff);

	for(i=0;i<r;i++) {
		printf(" ");
	}
	return 0;
}

static void dump(unsigned char *which) {

	int c,p=0,r;

	printf("\x1b[1;1H");

	while(1) {
		c=which[p]-OFFSET;

		if (c<16) {
			r=1;
			if (debug) fprintf(stderr,"%c C=%d R=1\n",which[p],c);
			decode(c&0xf,r);
		}
		else if (c<32) {
			r=2;
			if (debug) fprintf(stderr,"%c C=%d R=2\n",which[p],c&0xf);
			decode(c&0xf,r);
		}
		else {
			r=which[p+1]-OFFSET+2;
			if (debug) fprintf(stderr,"%c C=%d R=%d\n",which[p],c&0xf,r);
			decode(c&0xf,r);
			p++;
		}

		p++;
		if (which[p]=='~') break;
	}

}

static unsigned char *frames[]={
	rr3_even,rr3_odd,
	rr4_even,rr4_odd,
	rr5_even,rr5_odd,
	rr6_even,rr6_odd,
};


static int sequence[]={0,1,2,3,3,2,1,0};

int main(int argc, char **argv) {

	int which=0;

	if (argc>1) {
		which=atoi(argv[1]);
		dump(frames[which]);
	}
	else {
		which=0;
		while(1) {
			dump(frames[sequence[which]*2+1]);


			/* atari version = 60Hz/16 = 266ms */
			usleep(266000);
			which++;
			if (which>7) which=0;
		}
	}

	return 0;
}
