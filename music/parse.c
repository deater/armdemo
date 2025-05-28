/* This parses the cvs output from TIAtracker */

#include <stdio.h>
#include <string.h>

#include "common.h"

static int debug=1;

static int min_note=64,max_note=0;

static int convert_note(char *note) {

	int octave=0,raw,sharp=0,result;

	if (debug) fprintf(stderr,"Converting %s -- ",note);

	if (note[2]=='-') {
//		printf("-------------------\n");
		return '~';
	}


	switch(note[0]) {
		case 'C': raw=0; break;
		case 'D': raw=2; break;
		case 'E': raw=4; break;
		case 'F': raw=5; break;
		case 'G': raw=7; break;
		case 'A': raw=9; break;
		case 'B': raw=11; break;

		default:
			fprintf(stderr,"ERROR! %x\n",note[0]);
			return '~';
	}
	if (note[1]=='#') sharp++;

	octave=(note[2]-'0');

	result=(raw+sharp)+((octave-OCTAVE_START)*12);

	if (result>max_note) max_note=result;
	if (result<min_note) min_note=result;

	fprintf(stderr,"Got %d (%d %d %d)\n",result+OFFSET,raw,sharp,octave);

	return result+OFFSET;


}

static int numlens=0;
static int len_list[1024];



static void add_len(int len) {
	int i;

	for(i=0;i<numlens;i++) {
		if (len==len_list[i]) break;
	}
	if (i==numlens) {
		len_list[i]=len;
		numlens++;
	}

}

int main(int argc, char **argv) {

	char string[BUFSIZ];
	char *result, *token;
	char *saveptr1;
	int which,line=0;
	char note[4];

	int last='~',len=0;

	int output_ptr=0;
	int output_notes[1024];
	int output_lengths[1024];
	int i;


	while(1) {
		result=fgets(string,BUFSIZ,stdin);
		if (result==NULL) break;

		line++;

		/* skip header */
		if (line==1) continue;



		which=0;
		while(1) {
			if (which==0) {
				token = strtok_r(string,",", &saveptr1);
			}
			else {
				token = strtok_r(NULL,",", &saveptr1);
			}
			if (token == NULL) break;

			if (which==5) {
				note[0]=token[6];
				note[1]=token[7];
				note[2]=token[8];
				note[3]=0;
				len++;

				if ((note[0]!=' ') || (note[2]=='-')) {
//					if (debug) {
//						print_note(last);
//					}
					output_notes[output_ptr]=last;
					add_len(len);
					output_lengths[output_ptr]=len+OFFSET;
					output_ptr++;
					last=convert_note(note);
					len=0;
				}
			}
			which++;
		}
	}

	printf("unsigned char notes[]=\"");
	for(i=0;i<output_ptr;i++) {
		putchar(output_notes[i]);
	}
	printf("\";\n");

	printf("unsigned char lens[]=\"");
	for(i=0;i<output_ptr;i++) {
		putchar(output_lengths[i]);
	}
	printf("\";\n");

	printf("/* Found lens: ");
	for(i=0;i<numlens;i++) {
		printf("%d ",len_list[i]);
	}
	printf("*/\n");

	printf("/* Min: %d, Max: %d */\n",min_note,max_note);

	return 0;
}
