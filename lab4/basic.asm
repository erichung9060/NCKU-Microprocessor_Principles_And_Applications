List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    #define tmp 0x20
    
    Sub_Mul macro xh, xl, yh, yl
	MOVLW xl
	MOVWF tmp
	MOVLW yl
	SUBWF tmp, W // W = xl - yl
	MOVWF 0x001
	
	MOVLW xh
	MOVWF tmp
	MOVLW yh
	SUBWFB tmp, W // W = xh - yh
	MOVWF 0x000

	MOVF 0x000, W
	MULWF 0x001
	MOVFF PRODL, 0x011
	MOVFF PRODH, 0x010
    endm
	
    Sub_Mul 0xFF, 0xFF, 0x00, 0x01
    
end