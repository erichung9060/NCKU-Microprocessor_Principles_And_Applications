LIST p=18f4520
#include<pic18f4520.inc>

    CONFIG OSC = INTIO67 ; Set internal oscillator to 1 MHz
    CONFIG WDT = OFF     ; Disable Watchdog Timer
    CONFIG LVP = OFF     ; Disable Low Voltage Programming

    L1 EQU 0x14         ; Define L1 memory location
    L2 EQU 0x15         ; Define L2 memory location
    switch EQU 0x20
    i EQU 0x21
    zero EQU 0x22
    one EQU 0x23
    two EQU 0x24
    three EQU 0x25
 
    org 0x00            ; Set program start address to 0x00

; instruction frequency = 1 MHz / 4 = 0.25 MHz
; instruction time = 1/0.25 = 4 mu s
; Total_cycles = 2 + (2 + 8 * num1 + 3) * num2 cycles
; num1 = 111, num2 = 70, Total_cycles = 62512 cycles	
; Total_delay ~= Total_cycles * instruction time = 0.25 s

MOVLF macro literal, FileReg
    MOVLW literal
    MOVWF FileReg
endm
    
MOVLF 0, zero
MOVLF 1, one
MOVLF 2, two
MOVLF 3, three
    
DELAY macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles 
    LOOP2:
    MOVLW num1
    MOVWF L1
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ L1, 1
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2
endm

DELAY_AND_CHECK macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles 
    LOOP2:
    MOVLW num1
    MOVWF L1
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:
    BTFSS PORTB, 0      ; Check if PORTB bit 0 is low (button pressed)
    BRA button_click
    BTFSS PORTB, 0      ; Check if PORTB bit 0 is low (button pressed)
    BRA button_click
    NOP
    
    DECFSZ L1, 1
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2
endm
    
start:
int:
; let pin can receive digital signal
    MOVLW 0x0f          ; Set ADCON1 register for digital mode
    MOVWF ADCON1        ; Store WREG value into ADCON1 register
    CLRF PORTB          ; Clear PORTB
    BSF TRISB, 0        ; Set RB0 as input (TRISB = 0000 0001)
    CLRF LATA           ; Clear LATA
    BCF TRISA, 0        ; Set RA0 as output (TRISA = 0000 0000)
    BCF TRISA, 1        ; Set RA1 as output (TRISA = 0000 0000)
    BCF TRISA, 2        ; Set RA2 as output (TRISA = 0000 0000)
    BCF switch, 0
    
; Button check
main:
    BTFSS PORTB, 0      ; Check if PORTB bit 0 is low (button pressed)
    GOTO button_click
    GOTO main
    
button_click:
    DELAY 111, 70
    INCF switch, W
    
    CPFSGT three
    MOVLW 0 // W >= 3
    
    MOVWF switch
    
    CPFSLT zero
    GOTO light_down
    
    CPFSLT one
    GOTO light_up_state1
    
    GOTO light_up_state2
    

light_up_state1:
    MOVLF 0b00000001, LATA
    DELAY_AND_CHECK 200, 78 // delay 0.5
    
    MOVLF 0b00000010, LATA
    DELAY_AND_CHECK 200, 78 // delay 0.5
    
    MOVLF 0b00000100, LATA
    DELAY_AND_CHECK 200, 78 // delay 0.5
    
    GOTO light_up_state1

light_up_state2:
    MOVLF 0b00000001, LATA
    DELAY_AND_CHECK 200, 157 // delay 1
    
    MOVLF 0b00000010, LATA
    DELAY_AND_CHECK 200, 157 // delay 1
    
    CLRF LATA
    MOVLF 5, i
    loop:
	BTG LATA, 2
	DELAY_AND_CHECK 200, 78 // delay 0.5
	
	DECFSZ i
	GOTO loop
	
    GOTO light_up_state2
    
light_down:
    MOVLW 0
    MOVWF LATA
    
    GOTO main
end
    
    