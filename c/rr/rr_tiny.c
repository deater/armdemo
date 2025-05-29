#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

char A[]="~\\^__a^\\Z~\\\\^_ZZffa~\\^__a^\\Z~\\\\^_\\Zaaaca~_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\Zcca~ZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~__\\_a~^\\Z~\\\\^_\\Zffaca_\\\\^_\\_a^\\Z~\\\\^_\\Z~acca_~ac_aaacaZ~\\^_\\aca~ZZZ\\ccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\ZccaZZ\\Zf^_^\\ZZ\\Z_a^\\ZZa_~ZZ\\ZccaZZ\\Zaa_ZZ\\Z_a^\\ZZa_ZZ\\",
B[]="?<<<<<=;?E<<<<><><>D<<<<<=;?E<<<<<><<<<?=C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==?;;;;;><;;>;;;;><=;><>@B<<<<?=<<@@<<<<<@<<><<><<<<<<><<@@<<<<<?;<<>@C;<<<<<<<>>B<<<><<?;;;;;==@;;;;==@;;;;><=;><>B;;;;==@;;;;><;;>;;;;><=;><>@<;;;;==@;;;;==@;;;;><=;><>B;;;",
C[]="~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~D~D~B~B~D~D~B~B~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L~L~N~K~L",
D[]=";?;???;>@?;???;>@?;???;???;>@D@?;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;???;?",
E[]="ZxZxZxZxZxZxZl`<^<ZxZ>_>^>ZxZ<Nb@NZxZ<NTRd<NZxZ<QNQb>ZxZ>Q[<b<ZxZ>QVQRZxZBh<RZxZBh<RWh<ZxZ<h<QWhBZtOJVg<hDZnh<OJg<hHZjh@Jg<hHZjh@Jg<hHZjh@Jg<hHZjh@Jg<hJZhh@Jg<Qh@Yh>Zhh@Jg<a<h>Yh>Zhh@Jg<Xa<h<Yh@ZH~",
F[]="ZxZxZxZ>`<^<ZxZ@N_<^<ZxZ<`<b>NZxZ<PTQRSNZxZ<a>Ra<ZxZ<VQKb<QZxZ>QVQRZxZ@SQb<ZxZ@a>RXZxZ>a>Wh@ZvWh<g<hDZpXWh<WhHZjhDWhHZjh@Jg<hHZjh@Jg<hJZhh@JWXa<h@Yh>Zfh@JWXa<Rh>Yh@Zdh@JWXRQb<hFZfh>JWXi@hFZfh>JWXi@hFZdXYh<JWXiDh>ZhXYh<JWh<i@XZP~",
G[]="ZxZxZxZ>]<^<ZxZ@^<_<NZxZ>Na<RNZxZ>MQRSNZxZ<RPLRLQZxZ<a<VQRQZxZ>QVQRZxZ@a<RZxZBa<RZxZBa>Wh<Zv_<Wh<WhDZlXOXOWh<WhFZjh@Wh<WhFZjXYh>Jg<hFZjhBJg<hFZjhBJWhJZhhBJWh<Qb<Xi<h<Zfi>h<JWh<Qb<XYh@Zbh<i<h<JWh>a<YhBZbh@QXJWh>i>hDZbh<a>JWXiBhBZdi<Ra<JXiFZP~",
H[]="ZxZxZxZxZL`BZxZ>N_<^<ZxZ>TQRSTZxZ<TQKb<TZxZ<La<RTZxZ>a>KRQZxZ>Va<RZxZ@f<RZxZBa<RWZxZ>WQh<Wh<ZtOXOWJh<Wh@Znh@g<h<WhBZjhBg<JWhFZhhDWJWhFZhhDWJWhFZhXYh@WJhHZhXYh@WJhHZhXi<h>WJh>a<Rh<ZhXi<h>WJh>b<Qh<ZhXi<h>WJh>a>h<ZhXi>h<WJh>YQh>ZP~",
*sequence[]={E,F,G,H,H,G,F,E},
*b,*n,*l;

int f[64],o=0,w,j,d,colors[]={
0x909090,0xac783c,0xd0805c,0xe09470,
0x644818,0x442800,0x985c28,0xd07070,
0xe08888,0xeca0a0,0x846830,0xb03c3c,
0xc05858,0xc8c8c8,0x404040,0x2c3000
};

int decode(int c, int r) {

	int i;

	printf("\x1b[48;2;%d;%d;%dm",
			(colors[c]>>16)&0xff,
			(colors[c]>>8)&0xff,
			(colors[c]>>0)&0xff);

	for(i=0;i<r;i++) {
		printf(" ");
	}
	return 0;
}

void dump(char *which) {

	int c,p=0,r;

	printf("\x1b[1;1H");

	while(1) {
		c=which[p]-58;

		if (c<16) {
			r=1;
			decode(c&0xf,r);
		}
		else if (c<32) {
			r=2;
			decode(c&0xf,r);
		}
		else {
			r=which[p+1]-58+2;
			decode(c&0xf,r);
			p++;
		}

		p++;
		if (which[p]=='~') break;
	}

}

void a(char*N,char*L){for(n=N,l=L;*n;n++,l++){
d=(*l-58)*1000;w=(*n>'z')?0:8000/f[*n-58];
for(j=0;j<d;j++,o++)if(w&&(j%w<w/2))b[o]+=(j>d/2)?32:63;}}

int main(int argc, char **argv) {

	FILE *pipe;
	int i,which;
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
		which=0;
		while(1) {
			dump(sequence[which]);
			usleep(266000);
			which++;
			if (which>7) which=0;
		}
	}

	return 0;
}
