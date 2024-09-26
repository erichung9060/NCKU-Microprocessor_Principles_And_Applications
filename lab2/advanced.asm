List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    Count equ 0x20
    count equ 0x21

setup:
    LFSR 0, 0x100

    MOVLW 0x00
    MOVWF POSTINC0
    MOVLW 0x01
    MOVWF POSTINC0
    MOVLW 0x02
    MOVWF POSTINC0
    MOVLW 0x03
    MOVWF POSTINC0
    MOVLW 0x04
    MOVWF POSTINC0
    MOVLW 0x05
    MOVWF POSTINC0
    MOVLW 0x06
    MOVWF POSTINC0
    
    MOVLW 0x06
    MOVWF Count
    
LFSR 0, 0x100
loop_i:
    MOVF FSR0, W
    MOVWF FSR1
    INCF FSR1 // j = i + 1
    
    MOVLW 0x01
    MOVWF FSR1H
    
    MOVF Count, W
    MOVWF count
    
    loop_j:
	    MOVF INDF0, W
	    CPFSLT INDF1
	    GOTO skip_swap
	    GOTO swap

	swap:
	    XORWF INDF1, W // W = W(INDF0) ^ INDF1
	    XORWF INDF1
	    XORWF INDF1, W
	    MOVWF INDF0

	skip_swap:
	    INCF FSR1
	    DECFSZ count
	    GOTO loop_j
	    GOTO exit_j

    exit_j:
    INCF FSR0
    DECFSZ Count
    GOTO loop_i
    GOTO exit_i
    
exit_i:
end
