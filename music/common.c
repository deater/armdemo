#include <stdio.h>
#include <string.h>

#include "common.h"

#define OFFSET ':'
#define OCTAVE_START	2	// start at A2

static char notes[]= "CCDDEFFGGAAB";
static char sharps[]=" # #  # # # ";
static int debug=0;

/*  0 = C2 */
/* 12 = C3 */
/* 24 = C4 */
/* 36 = C5 */
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

	printf("%c%c%d",notes[n],sharps[n],octave);

	return;

}


#if 0

int main(int argc, char **argv) {

	int i;

	for(i=0;i<64;i++) {
		print_note(i+OFFSET);
		printf("\n");
	}

	return 0;
}


#endif
