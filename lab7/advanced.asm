#include "pic18f4520.inc"

#define GIE 7
#define IPEN 7
#define INT0IF 1
#define INT0IE 4
    
#define TMR2IF 1
#define TMR2IP 1
#define TMR2IE 1

#define C 0
#define DC 1
#define Z 2
#define OV 3
#define N 4
    
; CONFIG1H
  CONFIG  OSC = INTIO67         ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)

MOVLF macro literal, FileReg
    MOVLW literal
    MOVWF FileReg
endm
    
org 0x00
goto Initial

ISR:				
    org 0x08                ; Interrupt vector address
    INCF LATA               ; Increment LATA to track interrupts
    MOVLW 0b00001111
    ANDWF LATA, F           ; Mask LATA with 0x0F
    
    MOVLW 0
    SUBWF LATA, W           ; Check LATA value
    BZ change_mode1         ; Branch if LATA == 0
    
    MOVLW 4
    SUBWF LATA, W           ; Check LATA value
    BZ change_mode2         ; Branch if LATA == 4

    MOVLW 8
    SUBWF LATA, W           ; Check LATA value
    BZ change_mode3         ; Branch if LATA == 8
    
    goto finish             ; Skip to finish if no match
    
    change_mode1:
	MOVLF 61, PR2          ; Set PR2 to 61 for mode 1
	goto finish
	
    change_mode2:
	MOVLF 122, PR2         ; Set PR2 to 122 for mode 2
	goto finish
	
    change_mode3:
	MOVLF 244, PR2         ; Set PR2 to 244 for mode 3
	goto finish
    
    finish:
    BCF PIR1, TMR2IF        ; Clear Timer2 interrupt flag
    RETFIE                  ; Return from interrupt
    
; Initialization routine
Initial:			
    MOVLW 0x0F
    MOVWF ADCON1            ; Configure PORTA as digital I/O
    CLRF TRISA              ; Set PORTA as output
    CLRF LATA               ; Clear PORTA data latch
    BSF RCON, IPEN          ; Enable interrupt priority
    BSF INTCON, GIE         ; Enable global interrupts
    BCF PIR1, TMR2IF        ; Clear Timer2 interrupt flag
    BSF IPR1, TMR2IP        ; Set Timer2 interrupt to high priority
    BSF PIE1 , TMR2IE       ; Enable Timer2 interrupt
    MOVLW 0b11111111        ; Set Timer2 prescale and postscale to 1:16
    MOVWF T2CON             ; Enable Timer2 with prescaler and postscaler
    
    MOVLW 61                ; Set Timer2 period register for 0.5s delay
    MOVWF PR2
    
    MOVLW 0b00100000
    MOVWF OSCCON            ; Set internal oscillator frequency to 250 kHz
    
main:		
    bra main                ; Infinite loop
