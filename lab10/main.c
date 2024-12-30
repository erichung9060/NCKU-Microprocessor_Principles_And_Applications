#include <ctype.h>
#include <stdlib.h>

#include "setting_hardaware/setting.h"
#include "stdio.h"
#include "string.h"
#define _XTAL_FREQ 4000000  // 4M Hz
// using namespace std;
#define STR_MAX 100

char str[STR_MAX];
int is_interrupt = 0;

void Mode1() {  // Todo : Mode1
    while (1) {
        strcpy(str, GetString());
        ClearBuffer();
        for (int i = 0; i < strlen(str); i++) {
            if (isdigit(str[i])) {
                LATA = (((int)str[i] - 48) << 1);
            }
        }
    }
}

void Mode2() {  // Todo : Mode2
    while (1) {
        strcpy(str, GetString());
        ClearBuffer();
        for (int i = 0; i < strlen(str); i++) {
            if (isdigit(str[i])) {
                int val = (int)str[i] - 48;
                is_interrupt = 0;
                int now = val;
                while (!is_interrupt) {
                    LATA = now << 1;
                    __delay_ms(500);
                    now--;
                    if (now < 0) now = val;
                }
            }
        }
    }
}
void main() {
    SYSTEM_Initialize();

    while (1) {
        strcpy(str, GetString());  // TODO : GetString() in uart.c

        for (int i = 0; i + 1 < strlen(str); i++) {
            if (str[i] == 'm' && str[i + 1] == '1') {  // Mode1
                ClearBuffer();
                Mode1();
            } else if (str[i] == 'm' && str[i + 1] == '2') {  // Mode2
                ClearBuffer();
                Mode2();
            }
        }
    }
    return;
}

void __interrupt(high_priority) Hi_ISR(void) {
    if (INTCONbits.INT0IF == 1) {
        LATA = 0;
        is_interrupt = 1;
        // Disable Interrupt
        INTCONbits.INT0IF = 0;  // clear Interrupt flag bit (Interrupt 0 (Same as RB0 pin))
        __delay_ms(250);        // 0.25s
        return;
    }
    __delay_ms(250);  // 0.25s
    return;
}