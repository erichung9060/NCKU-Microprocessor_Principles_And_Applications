List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    MOVLW 0b11011111
    MOVWF TRISA
    
    RLNCF TRISA // left rotate
    BCF TRISA, 0 // remove the lowest bit 
    // TRISA = 10111110
    
    MOVF TRISA, W
    ANDLW 0b10000000 // get the highest bit
    
    RRNCF TRISA // right rotate
    IORWF TRISA // restore the highest bit
    end
    // TRISA = 11011111
    
    