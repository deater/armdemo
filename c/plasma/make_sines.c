#include <stdio.h>
#include <math.h>
#include <stdint.h>

int32_t double_to_fixed(double in) {

	int32_t x=0;

	x=round(in * (1 << 16));

	return x;
}

int32_t fixed_mul(int32_t x, int32_t y) {

	int64_t result,x1,y1;

	x1=x;
	y1=y;

	result=((x1*y1)>>16);

	return result;
}

int32_t our_sin(int32_t x) {

	int32_t result;
	int32_t x3,x5;
	int32_t x3t,x5t;

	// sin(x) ~= x - (x^3)/3!  + (x^5)/5! - (x^7)/7!

	x3=fixed_mul(x,x);
	x3=fixed_mul(x3,x);
	x3t=fixed_mul(x3,double_to_fixed(1.0/6.0));

	x5=fixed_mul(x3,x);
	x5=fixed_mul(x5,x);
	x5t=fixed_mul(x5,double_to_fixed(1.0/120.0));

	result=x-x3t+x5t;

	return result;
}

int main(int argc, char **argv) {

	double d;

	for(d=0;d<5.0;d+=0.25) {
		printf("%.2f: %X, sin(d)=%.2f = %X, our=%X diff=%d\n",
			d,double_to_fixed(d),
			sin(d),
			double_to_fixed(sin(d)),
			our_sin(double_to_fixed(d)),
			double_to_fixed(sin(d))-our_sin(double_to_fixed(d))
			);
	}

	for(d=0;d<5.0;d+=0.25) {
		printf("%.2f: %X\n",d,fixed_mul(double_to_fixed(d),
					double_to_fixed(d)));
	}

	return 0;
}
