# -----------------------------------------------------------
# test 4 LEDs

#include <pic18f4520.h>
#include <stdio.h>
#include <xc.h>
#define _XTAL_FREQ 1000000

#pragma config OSC = INTIO67  // Oscillator Selection bits
#pragma config WDT = OFF      // Watchdog Timer Enable bit
#pragma config PWRT = OFF     // Power-up Enable bit
#pragma config BOREN = ON     // Brown-out Reset Enable bit
#pragma config PBADEN = OFF   // Watchdog Timer Enable bit
#pragma config LVP = OFF      // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF      // Data EEPROM?Memory Code Protection bit (Data EEPROM code protection off)


void main(void) {
    // Set RC0, RC1, RC2, RC3 as digital output for the LEDs
    TRISC = 0;  // Set PORTC as output
    LATC = 0;   // Clear PORTC data latch

    int value = 1;
    while (1){
        LATC = value;
        __delay_ms(500);
        value <<= 1;
        if(value >= (1 << 4)) value = 1;
    }

    return;
}
