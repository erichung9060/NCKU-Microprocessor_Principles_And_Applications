List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    x_high equ 0x00
    x_low equ 0x01
    ans equ 0x02
    mask equ 0x20
    
    MOVLW 0xFF
    MOVWF x_high
    
    MOVLW 0xF1
    MOVWF x_low
    
    MOVLW 0b10000000
    MOVWF mask
    
    MOVLW 0xF
    MOVWF ans
    
    loop_high:
	MOVF x_high, W
	ANDWF mask, W // W = x & mask
	
	BTFSS STATUS, 2 
	GOTO find_high // x & mask != 0

	DECF ans

	BCF STATUS, 0
	RRCF mask // right rotate

	BTFSS STATUS, 2 // if mask == 0, break
	GOTO loop_high
    
    
    MOVLW 0b10000000
    MOVWF mask
    
    loop_low:
	MOVF x_low, W
	ANDWF mask, W // W = x & mask
	
	BTFSS STATUS, 2 
	GOTO find_low // x & mask != 0

	DECF ans

	BCF STATUS, 0
	RRCF mask // right rotate

	BTFSS STATUS, 2 // if mask == 0, break
	GOTO loop_low
    
	
    find_high:
	CPFSEQ x_high // x vs. (x & mask)
	GOTO add_one_to_answer
	
	MOVLW 0x00
	CPFSEQ x_low // x vs. 0
	GOTO add_one_to_answer
	GOTO finish
	
    find_low:
	CPFSEQ x_low // x vs. (x & mask)
	GOTO add_one_to_answer
	GOTO finish
	
    add_one_to_answer:
	MOVLW 0x01
	ADDWF ans
	
    finish:
    end
    