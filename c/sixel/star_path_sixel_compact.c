#include <stdio.h>
#include <unistd.h>
int main(int argc, char **argv) {
char*a="#%i;2;%d;%d;%d\n",fb[256][200],b[]="-\n#%d";
int f=0,c,d,x,y,p,r,s;
for(;;){for(x=0;x<256;x++) {for(y=0;y<200;y++) {d=14;
L:p=y*d; s=x-d;
if (s&256) c=((x+p)&255)?y/16+32:27;
else { c=((((s*d)|(p))>>8)&(d+f)); d++; if ((c&16)==0) goto L;
}fb[x][y]=c-16;}} usleep(1e4);f++;
puts("\n\033[1;1H\033Pq\n");
for(s=0;s<96;s+=6)printf(a,s/6,s,s,s),
printf(a,s/6+16,s>25?s>72?97-s:25:s,s>72?25:s>42?s-48:0,s<48?s<24?25:48-s:0);
for(y=0;y<200/6;y++) { *b='-'; for(c=0;c<32;c++) {
for(r=0;r<6;r++) for(x=0;x<256;x++) if (fb[x][y*6+r]==c) break;
if (r==6) { printf(b,c);*b='$';
for(x=0;x<256;x++) {
d=0; for(r=5;r>=0;r--) d=d<<1|(fb[x][y*6+r]==c);
putchar(d+'?');}}}}
puts("\n\033\\\n");}return 0;}
