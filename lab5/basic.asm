#include "xc.inc"
GLOBAL _mysqrt
PSECT mytext, local, class = CODE, reloc = 2

#define number 0x20
#define ans 0x21

MOVLF macro literal, FileReg
    MOVLW literal
    MOVWF FileReg
endm

_mysqrt:
    MOVWF number
    MOVLF 0x01, ans
    
    loop:
	INCF ans
    
	MOVF ans, W
	MULWF ans
	MOVF PRODL, W
	
	CPFSLT number
	GOTO loop // if ans*ans < number
	
    DECF ans
    
    MOVF ans, W
    RETURN