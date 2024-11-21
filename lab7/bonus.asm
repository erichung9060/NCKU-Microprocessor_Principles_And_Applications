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

L1 EQU 0x14
L2 EQU 0x15

DELAY macro num1, num2 
    local LOOP1 
    local LOOP2
    MOVLW num2
    MOVWF L2
    LOOP2:
	MOVLW num1
	MOVWF L1
    LOOP1:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ L1, 1
	BRA LOOP1
	DECFSZ L2, 1
	BRA LOOP2
endm

#define delay_mode 0x20
#define light_mode 0x21
#define final 0x22

org 0x00
goto Initial			    
ISR:
    org 0x08                ; 大致效果: 每0.5秒會進入一次interrupt
    
    BTFSS PIR1, TMR2IF
    GOTO BUTTON
    GOTO TIMER
    
    BUTTON:
	DELAY  111, 70
	CLRF LATA
	
	// delay_mode ++, 1 -> 2, 2 -> 1
	INCF delay_mode, F
	MOVLW 3
	SUBWF delay_mode, W // delay_mode >= 3
	BNZ continue1
	MOVLF 1, delay_mode
	continue1:

	// light_mode ++, 1 -> 2, 2 -> 3, 3 -> 1
	INCF light_mode, F
	MOVLW 4
	SUBWF light_mode, W // light_mode >= 4
	BNZ continue2
	MOVLF 1, light_mode
	continue2:

	MOVLW 1
	SUBWF delay_mode, W
	BZ change_delay_mode1

	MOVLW 2
	SUBWF delay_mode, W
	BZ change_delay_mode2

	change_delay_mode1:
	    MOVLF 61, PR2
	    goto next

	change_delay_mode2:
	    MOVLF 122, PR2
	    goto next

	next:

	MOVLW 1
	SUBWF light_mode, W
	BZ change_light_mode1

	MOVLW 2
	SUBWF light_mode, W
	BZ change_light_mode2

	MOVLW 3
	SUBWF light_mode, W
	BZ change_light_mode3

	change_light_mode1:
	    MOVLF 8, final
	    goto button_finish

	change_light_mode2:
	    MOVLF 16, final
	    goto button_finish

	change_light_mode3:
	    MOVLF 16, final
	    goto button_finish

	button_finish:
	BCF INTCON, INT0IF
	RETFIE
    
    TIMER:
	MOVLW 3
	SUBWF light_mode, W
	BZ light_mode3
	
	light_mode1_2:
	    INCF LATA, F
	    MOVF LATA, W
	    SUBWF final, W
	    BNZ timer_finish
	    CLRF LATA 
	    goto timer_finish
	
	light_mode3:
	    DECF LATA, F
	    BNN timer_finish
	    MOVFF final, LATA
	    goto timer_finish
	    
	timer_finish:
	BCF PIR1, TMR2IF        ; 離開前記得把TMR2IF清空 (清空flag bit)
	RETFIE
    
Initial:		
    MOVLW 0x0F
    MOVWF ADCON1
    
    CLRF TRISA
    CLRF LATA
    
    BSF RCON, IPEN
    BSF INTCON, GIE
    
    BCF PIR1, TMR2IF       ; 為了使用TIMER2，所以要設定好相關的TMR2IF、TMR2IE、TMR2IP。
    BSF IPR1, TMR2IP
    BSF PIE1 , TMR2IE
    MOVLW 0b11111111       ; 將Prescale與Postscale都設為1:16，意思是之後每256個週期才會將TIMER2+1
    MOVWF T2CON            ; 而由於TIMER本身會是以系統時脈/4所得到的時脈為主
    
    MOVLW 61              ; 因此每256 * 4 = 1024個cycles才會將TIMER2 + 1
    MOVWF PR2              ; 若目前時脈為250khz，想要Delay 0.5秒的話，代表每經過125000cycles需要觸發一次Interrupt
                           ; 因此PR2應設為 125000 / 1024 = 122.0703125， 約等於122。
    MOVLW 0b00100000
    MOVWF OSCCON           ; 記得將系統時脈調整成250kHz
    
    BSF TRISB,  0
    BCF INTCON, INT0IF
    BSF INTCON, INT0IE
    
    MOVLF 1, light_mode
    MOVLF 1, delay_mode
    MOVLF 8, final
    MOVLF 61, PR2
    
main:		
    bra main
    