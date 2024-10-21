#include <xc.h>
extern unsigned int multi_signed(unsigned char a, unsigned char b);

void main(void) {
    volatile unsigned int result = multi_signed(-1, 6);
    while(1);
    return;
}