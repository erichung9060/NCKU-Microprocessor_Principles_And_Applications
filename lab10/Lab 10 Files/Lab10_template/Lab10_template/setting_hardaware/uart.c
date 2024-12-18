#include <xc.h>
    //setting TX/RX

char mystring[20];
int lenStr = 0;

void UART_Initialize() {
           
    /*       TODObasic   
           Serial Setting      
        1.   Setting Baud rate
        2.   choose sync/async mode 
        3.   enable Serial port (configures RX/DT and TX/CK pins as serial port pins)
        3.5  enable Tx, Rx Interrupt(optional)
        4.   Enable Tx & RX
           
    TRISCbits.TRISC6 = ;            
    TRISCbits.TRISC7 = ;            
    
    //  Setting baud rate
    TXSTAbits.SYNC = ;           
    BAUDCONbits.BRG16 = ;          
    TXSTAbits.BRGH = ;
    SPBRG = ;      
    
   //   Serial enable
    RCSTAbits.SPEN = ;              
    PIR1bits.TXIF = ;
    PIR1bits.RCIF = ;
    TXSTAbits.TXEN = ;           
    RCSTAbits.CREN = ;             
    PIE1bits.TXIE = ;       
    IPR1bits.TXIP = ;             
    PIE1bits.RCIE = ;              
    IPR1bits.RCIP = ;    
    */          
    }

void UART_Write(unsigned char data)  // Output on Terminal
{
    while(!TXSTAbits.TRMT);
    TXREG = data;              //write to TXREG will send data 
}


void UART_Write_Text(char* text) { // Output on Terminal, limit:10 chars
    for(int i=0;text[i]!='\0';i++)
        UART_Write(text[i]);
}

void ClearBuffer(){
    for(int i = 0; i < 10 ; i++)
        mystring[i] = '\0';
    lenStr = 0;
}

void MyusartRead()
{
    /* TODObasic: try to use UART_Write to finish this function */
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