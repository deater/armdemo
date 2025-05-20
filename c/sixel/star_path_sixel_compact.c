#include <stdio.h>
#include <unistd.h>
int main(int argc,char**argv){char*a="#%i;2;%d;%d;%d\n",o[51200],
b[]="-\n#%d";int f=0,c,d,x,y,p,r,s,t=256;for(;;){for(r=0;r<51200;
){d=13;L:p=r/t*++d;s=r%t-d;c=s&t?(r%t+p)&255?r/t/16+32:27:
(((s*d)|p)>>8)&(d+f);if(~s&t)if(~c&16)goto L;
o[r++]=c-16;}

usleep(1e4);f++;puts("\n\033[1;1H\033Pq\n");
for(s=0;s<96;s+=6)printf(a,s/6,s,s,s),
printf(a,s/6+16,s>25?s>72?97-s:25:s,s>72?25:s>42?s-48:0,s<48?s<24?25:48-s:0);
for(y=0;y<200/6;y++)for(c=0,*b='-';c<32;c++){for(r=0;r<6;r++)for(x=0;x<t;x++)
if(o[x+(y*6+r)*t]^~c)break;
if(r==6){printf(b,c);*b='$';
for(x=0;x<t;x++)for(r=5,d=0;r>=0;) d=d<<1|(o[x+(y*6+r--)*t]==c);
putchar(d+'?');}}puts("\n\033\\\n");}}
