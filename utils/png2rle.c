#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "loadpng.h"
#include "rle_common.h"



/*****************************************/
/* Converts a PNG to RLE compressed data */
/*****************************************/


/* Converts a PNG to RLE compressed data */

int main(int argc, char **argv) {

	unsigned char *image;
	int xsize,ysize;
	int size=0;
	int out_type=OUTPUT_C;
	int skip=PNG_WHOLETHING;

	if (argc<3) {
		fprintf(stderr,"Usage:\t%s INFILE varname odd/even\n\n",argv[0]);
		fprintf(stderr,"\tvarname: label for graphic\n");
		fprintf(stderr,"\ttype: odd/even = o/e/w\n");
		fprintf(stderr,"\n");

		exit(-1);
	}

	out_type=OUTPUT_C;

	if (argc<4) {
	}
	else {
		if (argv[3][0]=='o') skip=PNG_ODDLINES;
		if (argv[3][0]=='e') skip=PNG_EVENLINES;
	}

	if (loadpng(argv[1],&image,&xsize,&ysize,skip)<0) {
		fprintf(stderr,"Error loading png!\n");
		exit(-1);
	}

	fprintf(stderr,"Loaded image %s,%d by %d\n",argv[1],xsize,ysize);

	size=rle_smaller(out_type,argv[2],
		xsize,ysize,image);

	fprintf(stderr,"Size %d bytes\n",size);

	return 0;
}




