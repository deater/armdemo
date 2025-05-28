#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define BUFFER_SIZE 16384

static int frequencies[12];

/* f=440*2^(n/12) */
static int generate_frequencies(void) {
	int i;
	float f;
	char notes[]= "AABCCDDEFFGG";
	char sharps[]=" #  # #  # #";

	for(i=0;i<12;i++) {
		f=440.0*pow(2,(float)i/12.0);
		frequencies[i]=f;
		printf("%c%c %f\n",notes[i],sharps[i],f);
	}

	return 0;
}

unsigned char music[]={0,1,2,3,4,5,6,7,8,9,10,11,0xff};

#define SAMPLE_FREQ	8000

unsigned char buffer[BUFFER_SIZE];
int offset=0;


void play_note(int note, int length) {

	int on, d,j;

	// 8000, 440   8000/440/2=
	on=SAMPLE_FREQ/frequencies[note];

	// 120bpm quaternote = 0.5 s */
	// assume 120bpm = 8000/(120/60) = 4000 long, sixteenth = 1000 long */
	d=length*(SAMPLE_FREQ/8);

	printf("Note:%d duration %d\n",note,d);
	for(j=0;j<d;j++) {
		if (j%on<on/2) {
			if (offset<BUFFER_SIZE) buffer[offset++]=0x7f;
		}
		else {
			if (offset<BUFFER_SIZE) buffer[offset++]=0x0;
		}
	}
}

int main(int argc, char **argv) {

	FILE *pipe;


	int i,note;

	generate_frequencies();

	i=0;
	while(1) {
		note=music[i];
		if (note==0xff) break;
		play_note(note,4);
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
