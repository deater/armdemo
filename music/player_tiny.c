#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

char A[]="~\\^__a^\\Z~\\\\^_ZZffa~\\^__a^\\Z~\\\\^_\\Zaaaca~_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\Zcca~ZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~__\\_a~^\\Z~\\\\^_\\Zffaca_\\\\^_\\_a^\\Z~\\\\^_\\Z~acca_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\ZccaZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~ZZ\\ZccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\",
B[]="?<<<<<=;?E<<<<><><>D<<<<<=;?E<<<<<><<<<?=C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==?;;;;;><;;>;;;;><=;><>@B<<<<?=<<@@<<<<<@<<><<><<<<<<><<@@<<<<<?;<<>@C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==@;;;;><;;>;;;;><=;><>@<;;;;==@;;;;==@;;;;><=;><>B;;;",
C[]="~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L",
D[]=";?;???;>@?;???;>@?;???;???;>@D@?;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;?",*b;

int f[64],o=0,w,j,d;
char *n,*l;

void a(char*N,char*L){for(n=N,l=L;*n;n++,l++){
d=(*l-58)*1000;w=(*n>'z')?0:8000/f[*n-58];
for(j=0;j<d;j++,o++)if(w&&(j%w<w/2))b[o]+=(j>d/2)?32:63;}}

int main(int argc, char **argv) {

	FILE *pipe;
	int i;
	for(i=0;i<64;i++) f[i]=440.0*pow(2,(float)(i-45)/12.0);
	if (!(b=calloc(704e3,1))) return 1;
	a(A,B);o=0;a(C,D);
	if (!fork() ) {
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
