# MOVLF
MOVLF macro literal, FileReg
    MOVLW literal
    MOVWF FileReg
endm

# -----------------------------------------------------------
# loop 1-D

counter equ 0x20
loop:
   
    ...
    
    DECFSZ counter
    GOTO loop

# -----------------------------------------------------------
# loop 2-D Count(n ~ 1), count(Count ~ 1)

Count equ 0x20
count equ 0x21
loop_i:
    MOVF Count, W
    MOVWF count
    
    loop_j:
	    ...

	    DECFSZ count
	    GOTO loop_j
	    GOTO exit_j
    exit_j:

    DECFSZ Count
    GOTO loop_i
    GOTO exit_i
    
exit_i:

# -----------------------------------------------------------
# check number

MOVLW 2
CPFSLT n
goto n_ge_2 // if n >= 2
TSTFSZ n
goto n_eq_1 // if n == 1
goto n_eq_0 // if n == 0

n_eq_0:
...	
goto finish

n_eq_1:
...
goto finish

n_ge_2:
...
goto finish

finish:

# -----------------------------------------------------------
# number compare 16-bits

MOVF b_h, W
SUBWF a_h, W
BZ continue1 // a_h == b_h

btfss   STATUS, 0
goto    exit // a_h < b_h
goto    continue2 // a_h > b_h

continue1: // a_h == b_h

MOVF b_l, W
SUBWF a_l, W
BZ continue2 // a_l == b_l

btfss   STATUS, 0
goto    exit // a_l < b_l
goto    continue2 // a_l > b_l

continue2: 

... do something when a >= b

exit:

# -----------------------------------------------------------
# gcd

#define a_l 0x01
#define a_h 0x02
#define b_l 0x03
#define b_h 0x04
#define a_mod_b_l 0x20
#define a_mod_b_h 0x21

gcd: 
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

