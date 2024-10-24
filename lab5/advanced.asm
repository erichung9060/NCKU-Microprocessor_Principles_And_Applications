#include "xc.inc"
GLOBAL _gcd
PSECT mytext, local, class = CODE, reloc = 2

#define a_l 0x01
#define a_h 0x02
#define b_l 0x03
#define b_h 0x04
#define a_mod_b_l 0x20
#define a_mod_b_h 0x21

_gcd: 
    while_gcd:
	// a = b, b = a % b
	RCALL a_mod_b
	MOVFF b_h, a_h
	MOVFF b_l, a_l
	MOVFF a_mod_b_h, b_h
	MOVFF a_mod_b_l, b_l
	
	MOVF b_h, W
	BNZ while_gcd
	MOVF b_l, W
	BNZ while_gcd
    
    RETURN
    
a_mod_b:
    MOVFF a_h, a_mod_b_h
    MOVFF a_l, a_mod_b_l
    
    while_mod:
	// a < b; return
	MOVF b_h, W
	SUBWF a_mod_b_h, W
	BZ continue1 // a_h == b_h
	
	btfss   STATUS, 0
	goto    exit // a_h < b_h
	goto    continue2 // a_h > b_h
    
	continue1: // a_h == b_h
	
	MOVF b_l, W
	SUBWF a_mod_b_l, W
	BZ continue2 // a_l == b_l
	
	btfss   STATUS, 0
	goto    exit // a_l < b_l
	goto    continue2 // a_l > b_l
	
	continue2: // a >= b
	
	// a -= b
	MOVF b_l, W
	SUBWF a_mod_b_l
    
	MOVF b_h, W
	SUBWFB a_mod_b_h
	
	GOTO while_mod
    
    exit:
    RETURN
