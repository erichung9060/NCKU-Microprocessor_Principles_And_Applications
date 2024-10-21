#include <xc.h>
extern unsigned int gcd(unsigned int a, unsigned int b);

void main(void) {
    volatile unsigned int result = gcd(1200, 180);
    while(1);
    return;
}