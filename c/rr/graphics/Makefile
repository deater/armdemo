PNG2RLE = ../../../utils/png2rle

all:	rr3_odd.h rr3_even.h \
	rr4_odd.h rr4_even.h \
	rr5_odd.h rr5_even.h \
	rr6_odd.h rr6_even.h

###

rr3_odd.h:	rr_frame3.png
	$(PNG2RLE) rr_frame3.png rr3_odd o > rr3_odd.h

rr3_even.h:	rr_frame3.png
	$(PNG2RLE) rr_frame3.png rr3_even e > rr3_even.h

###

rr4_odd.h:	rr_frame4.png
	$(PNG2RLE) rr_frame4.png rr4_odd o > rr4_odd.h

rr4_even.h:	rr_frame4.png
	$(PNG2RLE) rr_frame4.png rr4_even e > rr4_even.h

###

rr5_odd.h:	rr_frame5.png
	$(PNG2RLE) rr_frame5.png rr5_odd o > rr5_odd.h

rr5_even.h:	rr_frame5.png
	$(PNG2RLE) rr_frame5.png rr5_even e > rr5_even.h

###

rr6_odd.h:	rr_frame6.png
	$(PNG2RLE) rr_frame6.png rr6_odd o > rr6_odd.h

rr6_even.h:	rr_frame6.png
	$(PNG2RLE) rr_frame6.png rr6_even e > rr6_even.h


###

clean:	
	rm -f *.h
