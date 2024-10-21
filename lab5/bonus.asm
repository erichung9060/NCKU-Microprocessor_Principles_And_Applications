#include "xc.inc"
GLOBAL _multi_signed
PSECT mytext, local, class = CODE, reloc = 2

#define ans_l 0x01
#define ans_h 0x02
#define a 0x11
#define b 0x12
#define sign_bit 0x13
 
_multi_signed:
    MOVWF a
    MOVFF 0x01, b
    
    CLRF ans_l
    CLRF ans_h
    
    MOVF a
    BTFSC STATUS, 2
    RETURN // a == 0
    
    MOVF b
    BTFSC STATUS, 2
    RETURN // b == 0
    
    CLRF WREG
    BTFSS a, 7
    GOTO a_is_posiive
    a_is_negative:
	COMF a
	INCF a
	XORLW 1
    a_is_posiive:
    
    BTFSS b, 7
    GOTO b_is_posiive
    b_is_negative:
	COMF b
	INCF b
	XORLW 1
    b_is_posiive:
    MOVWF sign_bit
    
    while:
	MOVF a, W
	ADDWF ans_l
	MOVLW 0
	ADDWFC ans_h
	
	DECFSZ b
	GOTO while
 
    BTFSS sign_bit, 0
    GOTO ans_is_positive
    ans_is_negative:
	COMF ans_l
	COMF ans_h
	
	INCF ans_l
	MOVLW 0
	ADDWFC ans_h
    ans_is_positive:
    
    exit:
    RETURN