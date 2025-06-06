#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "common.h"

#include "music_track1.h"
#include "music_track2.h"

/* music size: 800 lines, each 1/16 note, 1000 samples each = 800k */

#define BUFFER_SIZE 1*1024*1024
#define SAMPLE_FREQ	8000

static int frequencies[64];

/* f=440*2^(n/12) */
static int generate_frequencies(void) {
	int i;
	float f;
	char notes[]= "CCDDEFFGGAAB";
	char sharps[]=" # #  # # # ";

	for(i=0;i<64;i++) {
		f=440.0*pow(2,(float)(i-45)/12.0);
		frequencies[i]=f;
		printf("%c%c%d %f\n",notes[i%12],sharps[i%12],(i/12)+1,f);
	}

	return 0;
}




unsigned char buffer[BUFFER_SIZE];
int offset=0;

static void play_note(int note, int length) {

	int on, d,j, volume;

	/* FIXME: maybe should use floating/fixed point to get */
	/*        more accurate frequencies.  Mostly an issue */
	/*	  with higher notes */

	if (note>64) {
		on=0;
	}
	else {
		// 8000, 440   8000/440/2=
		on=SAMPLE_FREQ/frequencies[note];
	}

	// 120bpm quaternote = 0.5 s */
	// assume 120bpm = 8000/(120/60) = 4000 long, sixteenth = 1000 long */
	d=length*(SAMPLE_FREQ/8);

//	printf("Note:%d duration %d\n",note,d);
	for(j=0;j<d;j++) {
		// add a bit of an envelope

		if (j>(d/2)) volume=0x40;
		else volume=0x7f;

		if (on==0) {
			if (offset<BUFFER_SIZE) buffer[offset++]=0x0;
		}
		else {

			if (j%on<on/2) {
				if (offset<BUFFER_SIZE) buffer[offset++]=volume;
			}
			else {
				if (offset<BUFFER_SIZE) buffer[offset++]=0x0;
			}
		}
	}
}


static void add_note(int note, int length) {

	int on, d,j, volume;

	/* FIXME: maybe should use floating/fixed point to get */
	/*        more accurate frequencies.  Mostly an issue */
	/*	  with higher notes */

	if (note>64) {
		on=0;
	}
	else {
		// 8000, 440   8000/440/2=
		on=SAMPLE_FREQ/frequencies[note];
	}

	// 120bpm quaternote = 0.5 s */
	// assume 120bpm = 8000/(120/60) = 4000 long, sixteenth = 1000 long */
	d=length*(SAMPLE_FREQ/8);

//	printf("Note:%d duration %d\n",note,d);
	for(j=0;j<d;j++) {
		// add a bit of an envelope

		if (j>(d/2)) volume=0x40;
		else volume=0x7f;

		if (on==0) {
			if (offset<BUFFER_SIZE) {
				buffer[offset]=(buffer[offset]+0)/2;
				offset++;
			}
		}
		else {

			if (j%on<on/2) {
				if (offset<BUFFER_SIZE) {
					buffer[offset]=(buffer[offset]+volume)/2;
					offset++;
				}
			}
			else {
				if (offset<BUFFER_SIZE) {
					buffer[offset]=(buffer[offset]+0)/2;
					offset++;
				}
			}
		}
	}
}


int main(int argc, char **argv) {

	FILE *pipe;


	int i,note,length;

	generate_frequencies();

	/* track 1 */
	i=0;
	while(1) {
		note=track1_notes[i];
		length=track1_lens[i];
		if (note==0) break;

		printf("Note %d: ",i);
		print_note(note);
		printf("length %d\n",length-OFFSET);

		play_note(note-OFFSET,length-OFFSET);

		i++;
	}

	/* track 2 */
	offset=0;
	i=0;
	while(1) {
		note=track2_notes[i];
		length=track2_lens[i];
		if (note==0) break;

		printf("Note %d: ",i);
		print_note(note);
		printf("length %d\n",length-OFFSET);

		add_note(note-OFFSET,length-OFFSET);

		i++;
	}


	pipe=popen("/usr/bin/aplay","w");
	if (pipe==NULL) {
		fprintf(stderr,"Error opening aplay!\n");
		exit(-1);
	}

	while(1) {
		fwrite(buffer,BUFFER_SIZE,1,pipe);
	}

	pclose(pipe);

	return 0;
}
