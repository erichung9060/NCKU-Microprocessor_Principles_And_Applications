List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    #define a1 0x00
    #define a2 0x01
    #define a3 0x02
    #define b1 0x10
    #define b2 0x11
    #define b3 0x12
    #define c1 0x20
    #define c2 0x21
    #define c3 0x22
    #define tmp1 0x30
    #define tmp2 0x31
    
    MOVLF macro literal, FileReg
        MOVLW literal
        MOVWF FileReg
    endm
    
    MUL macro x, y, ans
	MOVF x, W
	MULWF y
	MOVFF PRODL, ans
    endm
    
    GOTO main

    cross:
	MUL a2, b3, tmp1
	MUL a3, b2, tmp2
	MOVF tmp2, W
	SUBWF tmp1, W
	MOVWF c1
	
	MUL a3, b1, tmp1
	MUL a1, b3, tmp2
	MOVF tmp2, W
	SUBWF tmp1, W
	MOVWF c2
	
	MUL a1, b2, tmp1
	MUL a2, b1, tmp2
	MOVF tmp2, W
	SUBWF tmp1, W
	MOVWF c3
	
	return
	
	
    main:
	MOVLF 0x03, a1
	MOVLF 0x04, a2
	MOVLF 0x05, a3
	MOVLF 0x06, b1
	MOVLF 0x07, b2
	MOVLF 0x08, b3
    
	RCALL cross
end