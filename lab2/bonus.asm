List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    left equ 0x20
    right equ 0x21
    mid equ 0x22
    target equ 0x23

setup:
    LFSR 0, 0x000

    MOVLW 0x00
    MOVWF POSTINC0
    MOVLW 0x11
    MOVWF POSTINC0
    MOVLW 0x22
    MOVWF POSTINC0
    MOVLW 0x33
    MOVWF POSTINC0
    MOVLW 0x44
    MOVWF POSTINC0
    MOVLW 0x55
    MOVWF POSTINC0
    MOVLW 0x66
    MOVWF POSTINC0
    
    MOVLW 0x33
    MOVWF target
    
    LFSR 0, 0x000 // left = 0
    LFSR 1, 0x006 // right = 6

while:
    MOVF FSR1, W // while(left < right)
    CPFSLT FSR0 // F < W (left < right)
    GOTO end_while
    
    MOVF FSR0, W // W = left
    ADDWF FSR1,W // W = left + right
    RRCF WREG, W // W = (left + right) / 2
    MOVWF FSR2   // mid = W
    
    /*
	if(mid < target) l = mid + 1;
	else r = mid
    */
    MOVF target, W // W = target
    CPFSLT INDF2  // a[mid] < target
    GOTO left_half 
    GOTO right_half
	
    right_half: 
	MOVF FSR2, W
	ADDLW 0x01
	MOVWF FSR0 // l = mid + 1;
	GOTO while
	
    left_half:
	MOVF FSR2, W
	MOVWF FSR1 // r = mid
	GOTO while
 
end_while:
    MOVF INDF0, W 
    CPFSEQ target // if(a[l] == target)
    GOTO not_find
    GOTO find
    
    find:
	MOVLW 0xFF
	MOVWF 0x011
	GOTO exit

    not_find:
	MOVLW 0x00
	MOVWF 0x011
	GOTO exit

exit:
end