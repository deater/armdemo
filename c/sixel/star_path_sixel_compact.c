#include <stdio.h>
#include <unistd.h>
int main(int argc, char **argv) {
char fb[256][200],b[]="-\n#%d",*a="#%i;2;%d;%d;%d\n";
int f=0,c,d,x,y,yprime,t,row,v,s;
for(;;){for(x=0;x<256;x++) {for(y=0;y<200;y++) {d=14;
L:yprime=y*d; t=x-d;
if (t&256) c=((x+yprime)&255)?y/16+32:27;
else { c=((((t*d)|(yprime))>>8)&(d+f)); d++; if ((c&16)==0) goto L;
}fb[x][y]=c-16;}} usleep(10000);f++;
puts("\n\033[1;1H"); puts("\033Pq\n");
for(s=0;s<96;s+=6)printf(a,s/6,s,s,s),
printf(a,s/6+16,s>25?s>72?97-s:25:s,s>72?25:s>42?s-48:0,s<48?s<24?25:48-s:0);
 /* print a row 34*6=204 33*6=198*/
for(y=0;y<200/6;y++) { *b='-'; for(c=0;c<32;c++) {
for(row=0;row<6;row++) for(x=0;x<256;x++) if (fb[x][y*6+row]==c) break;
if (row==6) { printf(b,c);*b='$';
for(x=0;x<256;x++) {
v=0; for(row=5;row>=0;row--) v=v<<1|(fb[x][y*6+row]==c);
putchar(v+'?');}}}}
puts("\n\033\\\n");}return 0;}
