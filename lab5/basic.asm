#include "xc.inc"
GLOBAL _mysqrt
PSECT mytext, local, class = CODE, reloc = 2

#define number 0x20
#define ans 0x21
#define tmp 0x22
 
MOVLF macro literal, FileReg
    MOVLW literal
    MOVWF FileReg
endm

_mysqrt:
    MOVWF number
    MOVLF 0, ans
    
    loop:
	INCF ans
	MOVF ans, W
	
	MULWF ans
	MOVFF PRODL, tmp
	
	BTFSC STATUS, 1 // reach 16^2
	GOTO exit
	
	MOVF PRODL, W
	SUBWF number, W // W = number - ans*ans
	BZ exit // if ans*ans == number
	
	MOVF tmp, W
	CPFSLT number
	GOTO loop // if ans*ans < number
	
    exit:
    
    MOVF ans, W
    RETURN
