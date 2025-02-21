/* Bases on code by Hellmood for TIC-80 */

// For reference: "exotic" (128b version)
#include <stdio.h>
#include <unistd.h>

#include "mode13h.h"

/* 240*136??*/

/* TIC() is called at 60Hz */
/* code is in Lua */

static int t=0;


int main(int argc, char **argv) {

	int x,y,h,i,d;

	set_vga_pal();
	mode13h_graphics_init();

	while(1) {
		t=t-1;

		for(i=0;i<3840;i++) {
			d=0;
			x=i%80;
			y=i/80;

			do {
				d=d+1;
				//h=(d*(x-d)^(y*d))/256&(t-d);
				h=((d*(x-d)^(y*d))/32)&(t-d);
			} while((h&8)<=0);

//			if ((h<0) || (h>15)) h=0;
			pix(x,y,h);
		}

		mode13h_graphics_update();
		/* 60fps */
		usleep(33666);

		if (graphics_input()) {
			return 0;
		}
	}
}
