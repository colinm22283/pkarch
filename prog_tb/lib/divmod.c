unsigned int __umodsi3(unsigned int a, unsigned int b) {
    if (b == 0) return 0;
    
    unsigned int quotient = 0;
    unsigned int remainder = 0;
    
    for (int i = 31; i >= 0; i--) {
        remainder <<= 1;
        remainder |= (a >> i) & 1;
        if (remainder >= b) {
            remainder -= b;
            quotient |= (1U << i);
        }
    }
    return remainder;
}

unsigned int __udivsi3(unsigned int dividend, unsigned int divisor) {
    if (divisor == 0) {
        return 0;
    }
    
    unsigned int quotient = 0;
    unsigned int remainder = 0;
    
    for (int i = 31; i >= 0; i--) {
        remainder <<= 1;
        remainder |= (dividend >> i) & 1;
        if (remainder >= divisor) {
            remainder -= divisor;
            quotient |= (1U << i);
        }
    }
    return quotient;
}

