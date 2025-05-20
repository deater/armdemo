#include <stdio.h>
#include <unistd.h>

static unsigned char framebuffer[320][200];

static int check_color(int y, int c) {
	int x,row;

	for(row=0;row<6;row++) {
		for(x=0;x<320;x++) {
			if (framebuffer[x][y*6+row]==c) return 1;
		}
	}

	return 0;

}





int main(int argc, char **argv) {

	int frame=0,color,depth,x,y,yprime,xprime;
	int temp;

for(;;){
for(x=0;x<256;x++) {
for(y=0;y<200;y++) {
depth=14;	//  start ray depth at 14
L:
yprime=y*depth;	// Y'=Y * current depth
temp=x-depth;	// curve X by the current depth
// if left of the curve, jump to "sky"
if (temp&0x100) {
color=27-16;	// is both the star color and palette offset into sky
if (((x+yprime)&0xff)!=0) {
color=(color<<4)|(y>>4);
color-=160;
}
}
else {// multiply X by current depth (into AH)
xprime=temp*depth;// OR for geometry and texture pattern
temp=((xprime)|(yprime))>>8;	// get (current depth) + (current frame)
				// mask geometry/texture by time shifted depth
color=(temp&(depth+frame));// (increment depth by one)
depth++; // ... to create "gaps"
if ((color&0x10)==0) goto L;// if ray did not hit, repeat pixel loop
color-=16;
}
framebuffer[x][y]=color;
}
}
usleep(10000);
frame++;		// increment frame counter
puts("\n\033[1;1H");

int x,y,c,row,value;
int s=0;

/* start sixel */
puts("\033Pq\n");
/* setup palette */
char*a="#%i;2;%d;%d;%d\n";for(;s<96;s+=6)printf(a,s/6,s,s,s),
printf(a,s/6+16,s>25?s>72?97-s:25:s,s>72?25:s>42?s-48:0,s<48?s<24?25:48-s:0);

/* print a row 34*6=204 33*6=198*/
char b[]="-\n#%d";
for(y=0;y<200/6;y++) {
b[0]='-';
	for(c=0;c<32;c++) { // MAXCOLORS
			if (check_color(y,c)) {
				printf(b,c);
				b[0]='$';
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
return 0;
}
