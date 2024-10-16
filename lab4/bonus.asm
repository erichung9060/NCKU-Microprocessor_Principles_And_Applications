List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    #define n 0x10
    #define fi1_h 0x20    
    #define fi1_l 0x21
    #define fi2_h 0x22
    #define fi2_l 0x23
    #define tmp_h 0x24
    #define tmp_l 0x25
    #define ans_h 0x000
    #define ans_l 0x001
    
    MOVLW 15
    MOVWF n
    
    MOVLW 0
    MOVWF fi1_h
    MOVLW 0
    MOVWF fi1_l
    
    MOVLW 0
    MOVWF fi2_h
    MOVLW 1
    MOVWF fi2_l
    
    
    MOVLW 2
    CPFSLT n
    goto n_ge_2 // if n >= 2
    TSTFSZ n
    goto n_eq_1 // if n == 1
    goto n_eq_0 // if n == 0
    
    n_eq_0:
	MOVFF fi1_h, ans_h	
	MOVFF fi1_l, ans_l
	goto finish

    n_eq_1:
	MOVFF fi2_h, ans_h	
	MOVFF fi2_l, ans_l
	goto finish

    n_ge_2:
	RCALL fib
	MOVFF fi2_h, ans_h
	MOVFF fi2_l, ans_l
	goto finish
    
    fib:
	DCFSNZ n // if n == 0; return
	return
	
	// tmp = fib1 + fib2
	MOVF fi1_l, W
	ADDWF fi2_l, W
	MOVWF tmp_l
	
	MOVF fi1_h, W
	ADDWFC fi2_h, W
	MOVWF tmp_h
	
	// fib1 = fib2, fib2 = tmp
	MOVFF fi2_h, fi1_h
	MOVFF fi2_l, fi1_l
	MOVFF tmp_h, fi2_h
	MOVFF tmp_l, fi2_l
	GOTO fib
	
    finish:
    end
    