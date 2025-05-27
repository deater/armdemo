#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "rle_common.h"

/*****************************************/
/* Converts a PNG to RLE compressed data */
/*****************************************/

/* xxxxxx */
/* 1XCCCC RRRRRR -- color, run */
/* 00CCCC -- color, run = 1 */
/* 01CCCC -- color, run = 2 */
/* 0x3A (:) through 0x7A (z), ~ is terminator */

#define OFFSET ':'


static void our_putc(int value) {

	if (value=='\\') {
		putchar('\\');
		putchar('\\');
	}
	else {
		putchar(value);
	}
}

static int print_run(int count, int out_type, int run, int last) {

	int size=0;

	if (last>15) {
		printf("Error color too big %d\n",last);
	}

//	if (count==0) {
//		if (out_type==OUTPUT_C) {
//			printf("\n\t\"");
//		}
//	}

	if (run==1) {
		/* 00CCCC -- color, run = 1 */
		our_putc(last+OFFSET);
		size+=1;

	}
	if (run==2) {
		/* 01CCCC -- color, run = 2 */
		our_putc((last|0x10)+OFFSET);
		size+=1;
	}

	if ((run>2) && (run<66)) {
		/* 1XCCCC RRRRRR -- color, run */
		our_putc((last|0x20)+OFFSET);
		our_putc((run-2)+OFFSET);
		size+=2;

	}

	if (run>=66) {
		fprintf(stderr,"ERROR: TOO BIG %d!\n",run);
		exit(-1);
	}

	return size;
}


int rle_smaller(int out_type, char *varname,
		int xsize,int ysize, unsigned char *image) {

	int run=0;
	int x;

	int last=-1,next;
	int size=0;
	int count=0;

	x=0;

	/* Write out xsize and ysize */

	if (out_type==OUTPUT_C) {
		fprintf(stdout,"unsigned char %s[]=\"",varname);
	}

	size+=1;

	/* Get first top/bottom color pair */
	last=image[x];
	run++;
	x++;

	while(1) {

		/* get next top/bottom color pair */
		next=image[x];

		/* If color change (or too big) then output our run */
		if ((next!=last) || (run>63)) {

			size+=print_run(count,out_type,run,last);

			count++;
			run=0;
			last=next;
		}

		x++;

		/* If we reach the end */
		if (x>=xsize*(ysize/2)) {
			run++;

			size+=print_run(count,out_type,run,last);

			break;

		}

		run++;
		if (count>32) {
			count=0;
			printf("\"\n\t\"");
		}

	}

	/* Print closing marker */

	if (out_type==OUTPUT_C) {
		fprintf(stdout,"~\";\n");
	}

	size+=1;

	return size;
}

