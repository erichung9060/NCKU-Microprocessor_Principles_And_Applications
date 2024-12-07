#include <xc.h>
#include <pic18f4520.h>
#define _XTAL_FREQ 1000000

#pragma config OSC = INTIO67    // Oscillator Selection bits
#pragma config WDT = OFF        // Watchdog Timer Enable bit 
#pragma config PWRT = OFF       // Power-up Enable bit
#pragma config BOREN = ON       // Brown-out Reset Enable bit
#pragma config PBADEN = OFF     // Watchdog Timer Enable bit 
#pragma config LVP = OFF        // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF        // Data EEPROM?Memory Code Protection bit (Data EEPROM code protection off)

// Pulse Width: 500 ~ 2400 µs (-90° ~ 90°, 1450 µs = 0°)

void set_servo_angle(int angle) {
    /**
     * Duty cycle
     * = (CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)
     * = (0x0b*4 + 0b01) * 8µs * 4
     * = 0.00144s ~= 1450µs
     */
    if(angle == -90){
        CCPR1L = 3;
        CCP1CONbits.DC1B = 3;
    }else if(angle == 0){
        CCPR1L = 11;
        CCP1CONbits.DC1B = 1;
    }else if(angle == 90){
        CCPR1L = 18;
        CCP1CONbits.DC1B = 3;
    }
    __delay_ms(100);
}

int step = 0;
void __interrupt(high_priority) H_ISR(){
    if(INTCONbits.INT0IF!=1){
        return;
    }
    if(step == 0) set_servo_angle(-90);
    if(step == 1) set_servo_angle(0);
    if(step == 2) set_servo_angle(90);
    if(step == 3) set_servo_angle(0);
    step = (step + 1) % 4;
    
    // Clear interrupt flag
    INTCONbits.INT0IF=0;
}

void main(void)
{
    INTCONbits.INT0IF = 0;   // clear Interrupt flag bit
    INTCONbits.GIE = 0b1;    // open Global interrupt enable bit
    INTCONbits.INT0IE = 0b1; // open interrupt0 enable bit 
    
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;

    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 µs
    OSCCONbits.IRCF = 0b001;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
    // RB0 -> Input
    TRISB = 1;
    // CCP1/RC2 -> Output
    TRISC = 0;
    LATC = 0;
    
    // Set up PR2, CCP to decide PWM period and Duty Cycle
    /** 
     * PWM period
     * = (PR2 + 1) * 4 * Tosc * (TMR2 prescaler)
     * = (0x9b + 1) * 4 * 8µs * 4
     * = 0.019968s ~= 20ms
     */
    PR2 = 0x9b;
    
    set_servo_angle(-90);
    while(1);
    return;
}
