#include <stdio.h>
#include <string.h>

#define OFFSET ':'
#define OCTAVE_START	2	// start at A2

static char notes[]= "AABCCDDEFFGG";
static char sharps[]=" #  # #  # #";
static int debug=1;


static int convert_note(char *note) {

	int octave=0,raw,sharp=0,result;

	if (debug) fprintf(stderr,"Converting %s -- ",note);

	if (note[2]=='-') return '~';

	switch(note[0]) {
		case 'A': raw=0; break;
		case 'B': raw=2; break;
		case 'C': raw=3; break;
		case 'D': raw=5; break;
		case 'E': raw=7; break;
		case 'F': raw=8; break;
		case 'G': raw=10; break;
		default:
			fprintf(stderr,"ERROR! %x\n",note[0]);
			return '~';
	}
	if (note[1]=='#') sharp++;

	octave=(note[2]-'0');

	result=OFFSET+(raw+sharp)+((octave-OCTAVE_START)*12);
	fprintf(stderr,"Got %d (%d %d %d)\n",result,raw,sharp,octave);

	return result;


}




/* 0..63, add in ':' */

/*  0 = A2 */
/* 12 = A3 */
/* 24 = A4 */
/* 36 = A5 */
/* ~ means silence and 0 means end of song */
void print_note(int note) {

	int raw,octave,n;

	if (debug) fprintf(stderr,"\tPrinting %d (%d) -- ",note,note-OFFSET);

	if (note==0) return;

	if (note=='~') {
		printf("---");
		return;
	}

	raw=note-OFFSET;

	octave=(raw/12)+OCTAVE_START;
	n=raw%12;

	printf("%c%c%d\n",notes[n],sharps[n],octave);

	return;

}


int main(int argc, char **argv) {

	char string[BUFSIZ];
	char *result, *token;
	char *saveptr1;
	int which,line=0;
	char note[4];

	int last=0,len=0;

	int output_ptr=0;
	int output_notes[1024];
	int output_lengths[1024];
	int i;


	while(1) {
		result=fgets(string,BUFSIZ,stdin);
		if (result==NULL) break;

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

				if (note[0]!=' ') {
					last=convert_note(note);
					if (debug) {
						print_note(last);
					}
					output_notes[output_ptr]=last;
					output_lengths[output_ptr]=len+OFFSET;
					output_ptr++;
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

	return 0;
}
