#include <stdio.h>

int main(int argc, char **argv) {

	FILE *fff;
	int i,r,g,b,s;

	fff=fopen("new.txt","w");
	if (fff==NULL) return -1;

	/*******************************************************/

	/* grey gradient */
	for(s=0;s<96;s+=6) {
		fprintf(fff,"#%i;2;%d;%d;%d\n",s/6,s,s,s);
	}
	for(s=0;s<96;s+=6) {
		fprintf(fff,"#%i;2;%d;%d;%d\n",s/6+16,
		s>25?s>72?97-s:25:s,
		s>72?25:s>42?s-48:0,
		s<48?s<24?25:48-s:0);

	}


	/*******************************************************/
#if 0
	int i,r,g,b;

	/* grey gradient */
	for(i=0;i<16;i++) {
		fprintf(fff,"#%i;2;%d;%d;%d\n",i,i*6,i*6,i*6);
	}
	for(i=0;i<16;i++) {
		s=i*6;
		// 0 1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
		//              30 36 42 48 54  60 66 72 78 84 90
		//                                        6 12 18
		// 0 6 12 18 24 25 25 25 25 25  25 25 25 19 13  7

		r=s>25?s>72?97-s:25:s;

//		r=s>25?25-(s>72)*(s-72):s;

//		r=s>25?25:s;
//		if (s>72) r-=s-72;

		// i 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
		// s 0  6 12 18 24 30 36 42 48 54 60 66 72 78 84 90
		// g 0  0  0  0  0  0  0  0  0  6 12 18 24 25 25 25

		g=i>12?25:i>7?s-48:0;

//		g=i>12?25:(s-48)*(i>7);

//		g=(s-48)*(i>7);
//		g=g>25?25:g;

		// i 0   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
		// s 0   6 12 18 24 30 36 42 48 54 60 66 72 78 84 90
		// b 25 25 25 25 24 18 12  6  0  0  0  0  0  0  0  0

		b=i<8?i<4?25:48-s:0;

//		b=(48-s)*(i<9);
//		b=b>25?25:b;
		fprintf(fff,"#%i;2;%d;%d;%d\n",i+16,r,g,b);
	}
#endif

	fprintf(fff,"\n");
	fclose(fff);


	/**************************************************/

	fff=fopen("good.txt","w");
	if (fff==NULL) return -1;

	/* grey gradient */
	for(i=0;i<16;i++) {
		fprintf(fff,"#%i;2;%d;%d;%d\n",i,i*6,i*6,i*6);
	}

	/* colors for sunset */

	for(i=16;i<32;i++) {
		r=(i-16)*6;
		if (r>25) r=25;
		if ((i-16)>12) r-=6*(i-16-12);

		if ((i-16)<8) g=0;
		else {
			g=((i-24)*6);
		}
		if (g>25) g=25;

		/* 0 1 2 3 4 5 6 7 8 9 a b c d e f */
		/* f e d c b a 9 8 7 6 5 4 3 2 1 0 */
		/*             10 */
		if ((32-i)<8) b=0;
		else {
			b=((32-8-i)*6);
		}
		if (b>25) b=25;
		fprintf(fff,"#%i;2;%d;%d;%d\n",i,r,g,b);
	}
	fprintf(fff,"\n");
	fclose(fff);

	return 0;
}


