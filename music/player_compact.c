#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

#define OFFSET ':'
#define OCTAVE_START	1

char t1_notes[]="~\\^__a^\\Z~\\\\^_ZZffa~\\^__a^\\Z~\\\\^_\\Zaaaca~_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\Zcca~ZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~__\\_a~^\\Z~\\\\^_\\Zffaca_\\\\^_\\_a^\\Z~\\\\^_\\Z~acca_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\ZccaZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~ZZ\\ZccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\";
char t1_lens[]="?<<<<<=;?E<<<<><><>D<<<<<=;?E<<<<<><<<<?=C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==?;;;;;><;;>;;;;><=;><>@B<<<<?=<<@@<<<<<@<<><<><<<<<<><<@@<<<<<?;<<>@C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==@;;;;><;;>;;;;><=;><>@<;;;;==@;;;;==@;;;;><=;><>B;;;";
char t2_notes[]="~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L";
char t2_lens[]=";?;???;>@?;???;>@?;???;???;>@D@?;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;?";

/* music size: 704 lines, each 1/16 note, 1000 samples each = 704k */

#define BUFFER_SIZE 704000
#define SAMPLE_FREQ 8000

static int f[64];

char *buffer;
int offset=0;


static void add_note(int note, int length) {

	int on, d,j, volume;

	if (note>64) {
		on=0;
	}
	else {
		// 8000, 440   8000/440/2=
		on=SAMPLE_FREQ/f[note];
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

	for(i=0;i<64;i++) f[i]=440.0*pow(2,(float)(i-45)/12.0);

	if (!(buffer=calloc(BUFFER_SIZE,1))) return 1;

	/* track 1 */
	i=0;
	while(1) {
		note=t1_notes[i];
		length=t1_lens[i];
		if (note==0) break;
		add_note(note-OFFSET,length-OFFSET);

		i++;
	}

	/* track 2 */
	offset=0;
	i=0;
	while(1) {
		note=t2_notes[i];
		length=t2_lens[i];
		if (note==0) break;
		add_note(note-OFFSET,length-OFFSET);

		i++;
	}

	int pid;

	pid=fork();
	if (pid==0 ) {
		pipe=popen("/usr/bin/aplay","w");
		if (pipe==NULL) {
			fprintf(stderr,"Error opening aplay!\n");
			exit(-1);
		}
		while(1) {
			fwrite(buffer,BUFFER_SIZE,1,pipe);
		}
		pclose(pipe);
	}


	while(1) {
		printf("OOG\n");
		sleep(1);
	}




	return 0;
}


