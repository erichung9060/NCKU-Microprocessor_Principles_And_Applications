#include <pic18f4520.h>
#include <stdio.h>
#include <xc.h>
#define _XTAL_FREQ 4000000
#define delay(t) __delay_ms(t * 1000);
#define VR_MAX ((1 << 10) - 1)

#pragma config OSC = INTIO67    // Oscillator Selection bits
#pragma config WDT = OFF        // Watchdog Timer Enable bit 
#pragma config PWRT = OFF       // Power-up Enable bit
#pragma config BOREN = ON       // Brown-out Reset Enable bit
#pragma config PBADEN = OFF     // Watchdog Timer Enable bit 
#pragma config LVP = OFF        // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection bit

int get_LED(){
    return (LATA >> 1);
}

void set_LED(int value){
    LATA = (value << 1);
}

void set_LED_separately(int a, int b, int c){
    LATA = (a << 3) + (b << 2) + (c << 1);
}

void set_LED_analog(int value){
    CCPR1L = (value >> 2);
    CCP1CONbits.DC1B = (value & 0b11);
}

int current_servo_angle = 0;
int get_servo_angle(){
    // double duty_cycle = ((CCPR1L << 2) + CCP1CONbits.DC1B) * 8 * 4;
    // return (int)((duty_cycle - 500) / (2400 - 500) * 180 - 90);
    return current_servo_angle;
}

void set_servo_angle(int angle) {
    int current = (CCPR1L << 2) + CCP1CONbits.DC1B;
    int target = (int)((500 + (double)(angle + 90) / 180 * (2400 - 500)) / 8 / 4) * 8; // angle to pwn
    
    while(current != target){
        if(current < target) current++;
        else current--;
        
        CCPR1L = (current >> 2);
        CCP1CONbits.DC1B = (current & 0b11);
        __delay_ms(1);
    }
    current_servo_angle = angle;
}

int VR_value_to_servo_angle(int value){
    return (int)(((double)value / VR_MAX * 180) - 90);
}

int VR_value_to_LED_analog(int value){
    return value;
}

void variable_register_changed(int value);
void button_pressed();

void __interrupt(high_priority) H_ISR(){
    if(PIR1bits.ADIF){ // Handle variable register interrupt
        int value = (ADRESH << 8) + ADRESL;
        variable_register_changed(value);
        PIR1bits.ADIF = 0;
        __delay_ms(5);
    }
    
    if(INTCONbits.INT0IF){ // Handle button interrupt
        button_pressed();
        __delay_ms(10); // bouncing problem
        INTCONbits.INT0IF = 0;
    }
}

void init_all(){
    // Configure oscillator
    OSCCONbits.IRCF = 0b110;    // 4MHz for servo control
    
    // Configure ADC
    TRISAbits.RA0 = 1;          // Set RA0 as input port
    ADCON1bits.PCFG = 0b1110;   // AN0 as analog input
    ADCON0bits.CHS = 0b0000;    // Select AN0 channel
    ADCON1bits.VCFG0 = 0;       // Vref+ = Vdd
    ADCON1bits.VCFG1 = 0;       // Vref- = Vss
    ADCON2bits.ADCS = 0b000;    // ADC clock Fosc/2
    ADCON2bits.ACQT = 0b001;    // 2Tad acquisition time
    ADCON0bits.ADON = 1;        // Enable ADC
    ADCON2bits.ADFM = 1;        // Right justified
    
    // Configure servo (PWM)
    T2CONbits.TMR2ON = 0b1;     // Timer2 on
    T2CONbits.T2CKPS = 0b11;    // Prescaler 16
    CCP1CONbits.CCP1M = 0b1100; // PWM mode
    PR2 = 0x9b;                 // Set PWM period
    
    // Configure I/O ports
    TRISA &= 0xF1;              // Set RA1-RA3 as outputs for LED
    TRISB = 1;                  // RB0 as input for button
    TRISC = 0;                  // PORTC as output for servo
    LATA &= 0xF1;               // Clear RA1-RA3
    LATC = 0;                   // Clear PORTC
    
    // Configure interrupts
    INTCONbits.INT0IF = 0;      // Clear INT0 flag
    INTCONbits.INT0IE = 1;      // Enable INT0 interrupt
    PIE1bits.ADIE = 1;          // Enable ADC interrupt
    PIR1bits.ADIF = 0;          // Clear ADC flag
    INTCONbits.PEIE = 1;        // Enable peripheral interrupt
    INTCONbits.GIE = 1;         // Enable global interrupt
    
    // Start ADC conversion
    ADCON0bits.GO = 1;
}

void button_pressed(){
    // Do sth when the button is pressed
    
}

void variable_register_changed(int value){ // value: 0 ~ 1023
    // Do sth when the variable register changes
    /* Example:
     * set_servo_angle(VR_value_to_servo_angle(value));
     * set_LED_analog(VR_value_to_LED_analog(value));
     */
    
}

void main(){
    init_all();
    /* Usage:
     * set_servo_angle(-90); // input: -90 ~ 90
     * get_servo_angle(); // return value: -90 ~ 90
     * 
     * set_LED(5); // 5 = 0b101, set LED1 and LED3 on, LED2 off
     * get_LED(); // return value: an integer, bit 0 -> LED1, bit 1 -> LED2, bit 2 -> LED3
     * 
     * set_LED_separately(1, 1, 0); // set LED1 and LED2 on, LED3 off
     * set_LED_analog(512); // input: 0 ~ 1023, represent brightness. NOTICE: LED need to be plugged into the CCP1 pin.
     * 
     * VR_value_to_servo_angle(1024); // return value: -90 ~ 90. Change the variable register value to servo angle
     * VR_value_to_LED_analog(1024); // return value: 0 ~ 1024. Change the variable register value to LED brightness
     * 
     * delay(1); // delay 1 second
     */
    
    while(1) {
        // Do sth in main
        
        if(ADCON0bits.GO == 0) ADCON0bits.GO = 1;
    }
}
