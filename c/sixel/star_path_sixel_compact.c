/* A sixel version of Hellmood's amazing 64B DOS Star Path Demo */

#include <stdio.h>
#include <unistd.h>

#define MAX_COLORS	32

static unsigned char framebuffer[320][200];

static int colors_used[MAX_COLORS];

static void framebuffer_putpixel(unsigned int x, unsigned int y, unsigned char color) {

	if (x>320) return;
	if (y>200) return;

	colors_used[color]++;

	framebuffer[x][y]=color;

}

static int check_color(int y, int c) {
	int x,row;

	for(row=0;row<6;row++) {
		for(x=0;x<320;x++) {
			if (framebuffer[x][y*6+row]==c) return 1;
		}
	}

	return 0;

}



static void dump_framebuffer_sixel(void) {

	int x,y,c,row,value,newline;
	int i,r,g,b;

	printf("\033Pq\n");

	/* grey gradient */
	for(i=0;i<16;i++) {
		printf("#%i;2;%d;%d;%d",i,i*6,i*6,i*6);
	}

	/* colors for sunset */

for(i=16;i<32;i++){r=(i-16)*6;if(r>25)r=25;if((i-16)>12)r-=6*(i-16-12);if((i-
16)<8)g=0;else{g=((i-24)*6);}if(g>25)g=25;if((32-i)<8)b=0;else{b=((32-8-i)*6);}
if(b>25)b=25;printf("#%i;2;%d;%d;%d",i,r,g,b);}


#if 0
	for(i=16;i<32;i++) {
		r=(i-16)*6;
		if (r>25) r=25;
		if ((i-16)>12) r-=6*(i-16-12);

		if ((i-16)<8) g=0;
		else {
			g=((i-24)*6);
		}
		if (g>25) g=25;

		/* 0 1 2 3 4 5 6 7 8 9 a b c d e f */
		/* f e d c b a 9 8 7 6 5 4 3 2 1 0 */
		/*             10 */
		if ((32-i)<8) b=0;
		else {
			b=((32-8-i)*6);
		}
		if (b>25) b=25;
		printf("#%i;2;%d;%d;%d",i,r,g,b);
	}
#endif

	printf("\n");

	/* print a row */
	for(y=0;y<200/6;y++) {
		newline=1;
		for(c=0;c<MAX_COLORS;c++) {
			if (check_color(y,c)) {
				if (newline) {
					printf("-\n#%d",c);
					newline=0;
				}
				else {
					printf("$\n#%d",c);
				}
				for(x=0;x<320;x++) {
					value=0;
					for(row=5;row>=0;row--) {
						value<<=1;
						if (framebuffer[x][y*6+row]==c) {
							value|=1;
						}
					}
					printf("%c",value+'?');
				}
			}
		}

	}
	/* finished */
	printf("\n\033\\\n");

}

int main(int argc, char **argv) {

	int frame=0,color,depth,x,y,yprime,xprime;
	int temp;

	while(1) {

	for(x=0;x<256;x++) {
		for(y=0;y<200;y++) {

			depth=14;	//  start ray depth at 14
L:
			yprime=y*depth;	// Y'=Y * current depth

			temp=x-depth;	// curve X by the current depth

			// if left of the curve, jump to "sky"
			if (temp&0x100) {

				color=27-16;	// is both the star color and
						// palette offset into sky

				// pseudorandom multiplication leftover DL added to
				// truncated pixel count
				// 1 in 256 chance to be a star
				if (((x+yprime)&0xff)!=0) {
					// if not, shift the starcolor and add scaled pixel count
					color=(color<<4)|(y>>4);
					color-=160;
				}


			}
			else {
				// multiply X by current depth (into AH)
				xprime=temp*depth;

				// OR for geometry and texture pattern
				temp=((xprime)|(yprime))>>8;

				// get (current depth) + (current frame)
				// mask geometry/texture by time shifted depth
				color=(temp&(depth+frame));

				// (increment depth by one)
				depth++;

				// ... to create "gaps"

				if ((color&0x10)==0) goto L;

				// if ray did not hit, repeat pixel loop

				color-=16;
			}

			framebuffer_putpixel(x,y,color);
		}
	}
	usleep(10000);

	frame++;		// increment frame counter

	printf("\n%c[1;1H",27);


	dump_framebuffer_sixel();

	}



	return 0;

}


