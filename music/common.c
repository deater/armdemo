#include <stdio.h>
#include <string.h>

#include "common.h"

#define OFFSET ':'
#define OCTAVE_START	2	// start at A2

static char notes[]= "AABCCDDEFFGG";
static char sharps[]=" #  # #  # #";
static int debug=1;


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
