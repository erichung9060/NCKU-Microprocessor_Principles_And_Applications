#include <xc.h>

#include "test_uart.h"

void main(void) {
    char c;
    
    test_uart_init();
    while (c = test_uart_read()) {
        if (c == '\r')
            test_uart_write('\n');
        test_uart_write(c);
    }
    
    return;
}
