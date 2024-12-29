/*
Author: monkeyyo1104
Date: 2024/12/30
*/

#include "setting_hardaware/setting.h"
#include <stdlib.h>
#include <ctype.h>
#include "stdio.h"
#include "string.h"
#define _XTAL_FREQ 4000000 // 4M Hz
// using namespace std;

char str[20];
int interrupt = 0;

void Mode1(){   // Todo : Mode1 
    int cur = 2;
    while(cur < 20){
        strcpy(str, GetString());
        if(isdigit(str[cur]))
            LATA = (int)str[cur++] - 48;
    }
    return ;
}
void Mode2(){   // Todo : Mode2
    int cur = 2;
    while(cur < 20){
        strcpy(str, GetString());
        if(str[cur] == '\r' || str[cur] == ' '){
            LATA = 0;
            return;
        }
        else if(str[cur] != '\0'){
            int terminal = (int)str[cur++] - 48;
            int counter = 0;
            while(1){
                if(interrupt)
                    break;
                strcpy(str, GetString());
                if(str[cur] != '\0') 
                    break;
                LATA = counter++;
                __delay_ms(500); // 0.5s
                if(counter == terminal + 1)
                    counter = 0;
            }
            interrupt = 0;
        }
    }
    return ;
}
void main(void) 
{
    
    SYSTEM_Initialize() ;
    
    while(1) {
        strcpy(str, GetString()); // TODO : GetString() in uart.c
        for(int i = 0 ; i < 20 ; i++){
            if(str[i] == '\0')
                break;
            else if(str[i] == '\r' || str[i] == ' '){
                ClearBuffer();
                break;
            }
        }
        if(str[0] =='m' && str[1] =='1'){ // Mode1
            Mode1();
            ClearBuffer();
        }
        else if(str[0] =='m' && str[1] =='2'){ // Mode2
            Mode2();
            ClearBuffer();  
            interrupt = 0;
        }   
    }
    return;
}

void __interrupt(high_priority) Hi_ISR(void)
{
    if(INTCONbits.INT0IF == 1){
        LATA = 0;
        interrupt = 1;
        // Disable Interrupt
        INTCONbits.INT0IF = 0; // clear Interrupt flag bit (Interrupt 0 (Same as RB0 pin))
        __delay_ms(250); // 0.25s
        return;
    }
    __delay_ms(250); // 0.25s
    return;
}