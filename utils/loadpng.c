/* Loads a 80x48 (or 40x48) PNG image for conversion to ANSI */

#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include <png.h>
#include "loadpng.h"

static int debug=0;



static int lookup_color(int color) {

	int c=0;

	switch(color) {

		case 0x909090:	c=0; break;
		case 0xac783c:	c=1; break;
		case 0xd0805c:	c=2; break;
		case 0xe09470:	c=3; break;
		case 0x644818:	c=4; break;
		case 0x442800:	c=5; break;
		case 0x985c28:	c=6; break;
		case 0xd07070:	c=7; break;
		case 0xe08888:	c=8; break;
		case 0xeca0a0:	c=9; break;
		case 0x846830:	c=10; break;
		case 0xb03c3c:	c=11; break;
		case 0xc05858:	c=12; break;
		case 0xc8c8c8:	c=13; break;
		case 0x404040:	c=14; break;
		case 0x2c3000:	c=15; break;
		default:
			fprintf(stderr,"Unknown color %x\n",color);
			exit(-1);
			break;
	}

	return c;
}

#if 0
/* TODO: standard ANSI colors */
static int lookup_color(int color) {

	int c=0;

	switch(color) {
		case 0x000000:	c=0; break;	/* black */
		case 0xe31e60:	c=1; break;	/* magenta */
		case 0x604ebd:	c=2; break;	/* dark blue */
		case 0xff44fd:	c=3; break;	/* purple */
		case 0x00a360:	c=4; break;	/* dark green */
		case 0x9c9c9c:	c=5; break;	/* grey 1 */
		case 0x14cffd:	c=6; break;	/* medium blue */
		case 0xd0c3ff:	c=7; break;	/* light blue */
		case 0x607203:	c=8; break;	/* brown */
		case 0xff6a3c:	c=9; break;	/* orange */
		case 0x9d9d9d:	c=10; break;	/* grey 2 */
		case 0xffa0d0:	c=11; break;	/* pink */
		case 0x14f53c:	c=12; break;	/* bright green */
		case 0xd0dd8d:	c=13; break;	/* yellow */
		case 0x72ffd0:	c=14; break;	/* aqua */
		case 0xffffff:	c=15; break;	/* white */
		case 0xf5ff00:	c=10; break;	/* transparent */
		default:
			fprintf(stderr,"Unknown color %x, file %s\n",
				color,filename);
			exit(-1);
			break;
	}

	return c;
}








static int lookup_color_automatic(int color) {

#define MAX_COLORS 256
static int colors[MAX_COLORS];
static int num_colors=0;


	int i;
	/* first see if there */

	for(i=0;i<num_colors;i++) {
		if (colors[i]==color) break;
	}

	/* new color */
	if (i==num_colors) {
		colors[i]=color;
		if (debug) printf("found new color %d = %x\n",i,color);
		num_colors++;
	}

	return i;
}

#endif

/* expects a PNG where the xsize is 80 */

int loadpng(char *filename, unsigned char **image_ptr, int *xsize, int *ysize,
	int png_type) {

	int x,y,ystart,yadd,xadd;
	int color;
	FILE *infile;
	int debug=0;
	unsigned char *image,*out_ptr;
	int width, height;
	int a2_color;

	png_byte bit_depth;
	png_structp png_ptr;
	png_infop info_ptr;
	png_bytep *row_pointers;
	png_byte color_type;

	unsigned char header[8];

        /* open file and test for it being a png */
        infile = fopen(filename, "rb");
        if (infile==NULL) {
		fprintf(stderr,"Error!  Could not open %s\n",filename);
		return -1;
	}

	/* Check the header */
        fread(header, 1, 8, infile);
        if (png_sig_cmp(header, 0, 8)) {
		fprintf(stderr,"Error!  %s is not a PNG file\n",filename);
		return -1;
	}

        /* initialize stuff */
        png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        if (!png_ptr) {
		fprintf(stderr,"Error create_read_struct\n");
		exit(-1);
	}

        info_ptr = png_create_info_struct(png_ptr);
        if (!info_ptr) {
		fprintf(stderr,"Error png_create_info_struct\n");
		exit(-1);
	}

	png_init_io(png_ptr, infile);
	png_set_sig_bytes(png_ptr, 8);

	png_read_info(png_ptr, info_ptr);

	width = png_get_image_width(png_ptr, info_ptr);
	height = png_get_image_height(png_ptr, info_ptr);

	if (width==80) {
		*xsize=80;
		xadd=1;
	}
	else {
		fprintf(stderr,"Unsupported width %d\n",width);
		return -1;
	}

	if (png_type==PNG_WHOLETHING) {
		*ysize=height;
		ystart=0;
		yadd=1;
	}
	else if (png_type==PNG_ODDLINES) {
		*ysize=height;
		ystart=1;
		yadd=2;
	}
	else if (png_type==PNG_EVENLINES) {
		*ysize=height;
		ystart=0;
		yadd=2;
	}
	else {
		fprintf(stderr,"Unknown PNG type\n");
		return -1;
	}

	color_type = png_get_color_type(png_ptr, info_ptr);
	bit_depth = png_get_bit_depth(png_ptr, info_ptr);

	if (debug) {
		printf("PNG: width=%d height=%d depth=%d\n",width,height,bit_depth);
		if (color_type==PNG_COLOR_TYPE_RGB) printf("Type RGB\n");
		else if (color_type==PNG_COLOR_TYPE_RGB_ALPHA) printf("Type RGBA\n");
		else if (color_type==PNG_COLOR_TYPE_PALETTE) printf("Type palette\n");
		printf("Generating output size %d x %d\n",*xsize,*ysize);
	}

//        number_of_passes = png_set_interlace_handling(png_ptr);
	png_read_update_info(png_ptr, info_ptr);

	row_pointers = (png_bytep*) malloc(sizeof(png_bytep) * height);
	for (y=0; y<height; y++) {
		/* FIXME: do we ever free these? */
		row_pointers[y] = (png_byte*) malloc(png_get_rowbytes(png_ptr,info_ptr));
	}

	png_read_image(png_ptr, row_pointers);

	fclose(infile);


	image=calloc(width*height,sizeof(unsigned char));
	if (image==NULL) {
		fprintf(stderr,"Memory error!\n");
		return -1;
	}
	out_ptr=image;

	if (color_type==PNG_COLOR_TYPE_RGB_ALPHA) {
		for(y=ystart;y<height;y+=yadd) {
			for(x=0;x<width;x+=xadd) {

				/* top color */
				color=	(row_pointers[y][x*xadd*4]<<16)+
					(row_pointers[y][x*xadd*4+1]<<8)+
					(row_pointers[y][x*xadd*4+2]);
				if (debug) {
					printf("%x ",color);
				}

				a2_color=lookup_color(color);


				*out_ptr=a2_color;
				out_ptr++;
			}
			if (debug) printf("\n");
		}
	}
	if (color_type==PNG_COLOR_TYPE_RGB) {
		for(y=ystart;y<height;y+=yadd) {
			for(x=0;x<width;x+=xadd) {

				/* top color */
				color=	(row_pointers[y][x*xadd*3]<<16)+
					(row_pointers[y][x*xadd*3+1]<<8)+
					(row_pointers[y][x*xadd*3+2]);
				if (debug) {
					printf("%x ",color);
				}

				a2_color=lookup_color(color);


				*out_ptr=a2_color;
				out_ptr++;
			}
			if (debug) printf("\n");
		}
	}
	else if (color_type==PNG_COLOR_TYPE_PALETTE) {
		for(y=ystart;y<height;y+=yadd) {
			for(x=0;x<width;x+=xadd) {

				if (bit_depth==8) {
					/* top color */
					a2_color=row_pointers[y][x];

					if (debug) {
						printf("%x ",a2_color);
					}

					*out_ptr=a2_color;
					out_ptr++;
				}
				else if (bit_depth==4) {
					/* top color */
					a2_color=row_pointers[y][x/2];
					if (x%2==0) {
						a2_color=(a2_color>>4);
					}
					a2_color&=0xf;

					if (debug) {
						printf("%x ",a2_color);
					}

					*out_ptr=a2_color;
					out_ptr++;

				}
			}
			if (debug) printf("\n");
		}
	}
	else {
		printf("Unknown color type %d\n",color_type);
	}


	*image_ptr=image;

	return 0;
}


