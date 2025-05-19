#include <stdio.h>

int main(int argc, char **argv) {

	FILE *fff;
	int i,r,g,b;

	fff=fopen("new.txt","w");
	if (fff==NULL) return -1;

	/* grey gradient */
	for(i=0;i<16;i++) {
		fprintf(fff,"#%i;2;%d;%d;%d",i,i*6,i*6,i*6);
	}

	/* colors for sunset */

	for(i=16;i<32;i++) {
		r=(i-16)*6;
		if (r>25) r=25;
		if ((i-16)>12) r-=6*(i-28);

		if ((i-16)<8) g=0;
		else {
			g=((i-24)*6);
		}
		if (g>25) g=25;

		if ((32-i)<8) b=0;
		else {
			b=((32-8-i)*6);
		}
		if (b>25) b=25;
		fprintf(fff,"#%i;2;%d;%d;%d",i,r,g,b);
	}
	fprintf(fff,"\n");
	fclose(fff);

	/**************************************************/

	fff=fopen("good.txt","w");
	if (fff==NULL) return -1;

	/* grey gradient */
	for(i=0;i<16;i++) {
		fprintf(fff,"#%i;2;%d;%d;%d",i,i*6,i*6,i*6);
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
		fprintf(fff,"#%i;2;%d;%d;%d",i,r,g,b);
	}
	fprintf(fff,"\n");
	fclose(fff);

	return 0;
}


