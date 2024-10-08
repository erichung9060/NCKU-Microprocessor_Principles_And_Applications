List p=18f4520
#include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    A_H equ 0x00
    A_L equ 0x01
    B_H equ 0x10
    B_L equ 0x11
    ans4 equ 0x20
    ans3 equ 0x21
    ans2 equ 0x22
    ans1 equ 0x23
    
    MOVLW 0x77
    MOVWF A_H
    MOVLW 0x77
    MOVWF A_L
    
    MOVLW 0x56
    MOVWF B_H
    MOVLW 0x78
    MOVWF B_L
    
    CLRF ans1
    CLRF ans2
    CLRF ans3
    CLRF ans4
    
    MOVF A_L, W
    MULWF B_L
    MOVF PRODL, W
    ADDWF ans1
    MOVF PRODH, W
    ADDWFC ans2

    MOVF A_L, W
    MULWF B_H
    MOVF PRODL, W
    ADDWF ans2
    MOVF PRODH, W
    ADDWFC ans3
    
    MOVF A_H, W
    MULWF B_L
    MOVF PRODL, W
    ADDWF ans2
    MOVF PRODH, W
    ADDWFC ans3
    
    MOVF A_H, W
    MULWF B_H
    MOVF PRODL, W
    ADDWF ans3
    MOVF PRODH, W
    ADDWFC ans4
 
end   