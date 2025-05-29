#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

char t1_n[]="~\\^__a^\\Z~\\\\^_ZZffa~\\^__a^\\Z~\\\\^_\\Zaaaca~_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\Zcca~ZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~__\\_a~^\\Z~\\\\^_\\Zffaca_\\\\^_\\_a^\\Z~\\\\^_\\Z~acca_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\ZccaZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~ZZ\\ZccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\",
t1_l[]="?<<<<<=;?E<<<<><><>D<<<<<=;?E<<<<<><<<<?=C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==?;;;;;><;;>;;;;><=;><>@B<<<<?=<<@@<<<<<@<<><<><<<<<<><<@@<<<<<?;<<>@C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==@;;;;><;;>;;;;><=;><>@<;;;;==@;;;;==@;;;;><=;><>B;;;",
t2_n[]="~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L",
t2_l[]=";?;???;>@?;???;>@?;???;???;>@D@?;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;?",*b;

static int f[64];

int o=0;


void add_note(int n, int l) {
int w,d,j,v;
if(n>64) w=0;
else w=8000/f[n];
d=l*1000;
for(j=0;j<d;j++) {
	if (j>(d/2)) v=0x40;
	else v=0x7f;

	if (w==0) b[o]=b[o]/2;
	else {
		if (j%w<w/2) b[o]=(b[o]+v)/2;
		else b[o]=b[o]/2;
	}
	o++;
}
}


int main(int argc, char **argv) {

	FILE *pipe;
	int i,note,length;

	for(i=0;i<64;i++) f[i]=440.0*pow(2,(float)(i-45)/12.0);

	if (!(b=calloc(704000,1))) return 1;

	/* track 1 */
	i=0;
	while(1) {
		note=t1_n[i];
		length=t1_l[i];
		if (note==0) break;
		add_note(note-58,length-58);

		i++;
	}

	/* track 2 */
	o=0;
	i=0;
	while(1) {
		note=t2_n[i];
		length=t2_l[i];
		if (note==0) break;
		add_note(note-58,length-58);

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
			fwrite(b,704000,1,pipe);
		}
		pclose(pipe);
	}


	while(1) {
		printf("OOG\n");
		sleep(1);
	}




	return 0;
}
