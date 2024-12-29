/*
Author: monkeyyo1104
Date: 2024/12/30
*/

#include <xc.h>
    //setting TX/RX

char mystring[20];
int lenStr = 0;

void UART_Initialize() {
    /*     
           TODObasic   
           Serial Setting      
        1.   Setting Baud rate
        2.   choose sync/async mode 
        3.   enable Serial port (configures RX/DT and TX/CK pins as serial port pins)
        3.5  enable Tx, Rx Interrupt(optional)
        4.   Enable Tx & RX
    */       
    TRISCbits.TRISC6 = 1;    // RC6(TX) : Transmiter set 1 (output)        
    TRISCbits.TRISC7 = 1;    // RC7(RX) : Receiver set 1   (input)
    
    // Setting Baud rate
    // Baud rate = 1200 (Look up table)
    TXSTAbits.SYNC = 0;    // Synchronus or Asynchronus       
    BAUDCONbits.BRG16 = 0; // 16 bits or 8 bits 
    TXSTAbits.BRGH = 0;    // High Baud Rate Select bit
    SPBRG = 51;            // Control the period
    
   // Serial enable
    RCSTAbits.SPEN = 1;  // Enable asynchronus serial port (must be set to 1)              
    PIR1bits.TXIF  = 0;  // Set when TXREG is empty
    PIR1bits.RCIF  = 0;  // Will set when reception is complete
    TXSTAbits.TXEN = 1;  // Enable transmission         
    RCSTAbits.CREN = 1;  // Continuous receive enable bit, will be cleared when error occured           
    PIE1bits.TXIE  = 0;  // Wanna use Interrupt (Transmit)    
    IPR1bits.TXIP  = 0;  // Interrupt Priority bit         
    PIE1bits.RCIE  = 1;  // Wanna use Interrupt (Receive)       
    IPR1bits.RCIP  = 0;  // Interrupt Priority bit
    /* Transmitter (output)
     TSR   : Current Data
     TXREG : Next Data
     TXSTAbits.TRMT will set when TSR is empty
    */
    /* Reiceiver (input)
     RSR   : Current Data
     RCREG : Correct Data (have been processed) : read data by reading the RCREG Register
    */ 
    }

void UART_Write(unsigned char data)  // Output on Terminal
{
    while(!TXSTAbits.TRMT);    // Busy Waiting
    TXREG = data;              // write to TXREG will send data 
}


void UART_Write_Text(char* text) { // Output on Terminal, limit:10 chars
    for(int i=0;text[i]!='\0';i++)
        UART_Write(text[i]);
}

void ClearBuffer(){
    for(int i = 0; i < 20 ; i++)
        mystring[i] = '\0';
    lenStr = 0;
}

void MyusartRead()
{
    /* TODObasic: try to use UART_Write to finish this function */
    char data;
    data = RCREG;
    mystring[lenStr++] = RCREG;
    if(data == '\r')
        UART_Write('\n');
    UART_Write(data);
    if(lenStr == 19)
        lenStr = 0;
    return ;
}

char *GetString(){
    return mystring;
}


// void interrupt low_priority Lo_ISR(void)
void __interrupt(low_priority)  Lo_ISR(void)
{
    if(RCIF)
    {
        if(RCSTAbits.OERR)
        {
            CREN = 0;
            Nop();
            CREN = 1;
        }
        
        MyusartRead();
    }
    
   // process other interrupt sources here, if required
    return;
}