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
#define ADC_MAX ((1 << 10) - 1)


void set_LED_brightness(int duty) {
    CCPR1L = (duty >> 2) & 0xFF;    // high 8 bits
    CCP1CONbits.DC1B = duty & 0x03; // low 2 bits
}

void PWM_Init(){
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;

    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 µs
    OSCCONbits.IRCF = 0b001;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
    // CCP1/RC2 -> Output
    TRISC = 0;
    LATC = 0;
    
    // Set PWM Period（20 ms）
    PR2 = 0x9b;
}

void ADC_Init(){
    // Set RA0(AN0) as analog input(variable resistor)
    TRISAbits.RA0 = 1;         // Set RA0 as input port
    ADCON1bits.PCFG = 0b1110;  // AN0 as analog input, others as digital
    ADCON0bits.CHS = 0b0000;   // Select AN0 channel

    // Set RC0, RC1, RC2, RC3 as digital output for the LEDs
    TRISC = 0;  // Set PORTC as output
    LATC = 0;   // Clear PORTC data latch

    // configure OSC
    OSCCONbits.IRCF = 0b100;  // 1MHz

    // step1
    ADCON1bits.VCFG0 = 0;     // Vref+ = Vdd
    ADCON1bits.VCFG1 = 0;     // Vref- = Vss
    ADCON2bits.ADCS = 0b000;  // ADC clock Fosc/2
    ADCON2bits.ACQT = 0b001;  // Tad = 2 us acquisition time set 2Tad = 4 > 2.4
    ADCON0bits.ADON = 1;      // Enable ADC
    ADCON2bits.ADFM = 1;      // right justified

    // step2
    PIE1bits.ADIE = 1;    // Enable ADC interrupt
    PIR1bits.ADIF = 0;    // Clear ADC interrupt flag
    INTCONbits.PEIE = 1;  // Enable peripheral interrupts
    INTCONbits.GIE = 1;   // Enable global interrupts

    // step3
    ADCON0bits.GO = 1;  // Start ADC conversion
}

void __interrupt(high_priority) H_ISR() {
    // step4
    int value = (ADRESH << 8) + ADRESL;

    
    if(value < ADC_MAX / 2) value = value * 2;  // map to 0 ~ 1024
    else value = (ADC_MAX - value) * 2; // map to 1024 ~ 0
    
    set_LED_brightness(value);

    // clear flag bit
    PIR1bits.ADIF = 0;

    // step5 & go back step3
    __delay_ms(5);  // delay at least 2tad
    ADCON0bits.GO = 1;
}

void main(void)
{
    PWM_Init();
    ADC_Init();

    while (1);
    return;
}