unsigned int __mulsi3(unsigned int a, unsigned int b) {
    unsigned int r = 0;

    while (a) {
        if (a & 1) r += b;

        a >>= 1;
        b <<= 1;
    }

    return r;
}

static unsigned int udivmod32(unsigned int n, unsigned int d, unsigned int *rem) {
    unsigned int q = 0, r = 0;
 
    if (d == 0) {
        if (rem) *rem = n;
        return ~0u;
    }
    if (d > n) {
        if (rem) *rem = n;
        return 0;
    }
 
    int i = 31;
    while (!(n >> i))
        --i;
 
    for (; i >= 0; --i) {
        r = (r << 1) | ((n >> i) & 1u);
        if (r >= d) {
            r -= d;
            q |= 1u << i;
        }
    }
 
    if (rem) *rem = r;
    return q;
}
 
unsigned int __udivsi3(unsigned int n, unsigned int d) {
    return udivmod32(n, d, 0);
}
 
unsigned int __umodsi3(unsigned int n, unsigned int d) {
    unsigned int r;
    udivmod32(n, d, &r);
    return r;
}
 
int __divsi3(int a, int b) {
    unsigned int ua = a < 0 ? -(unsigned int)a : (unsigned int)a;
    unsigned int ub = b < 0 ? -(unsigned int)b : (unsigned int)b;
    unsigned int q  = udivmod32(ua, ub, 0);
 
    return ((a ^ b) < 0) ? (int)-q : (int)q;
}
 
int __modsi3(int a, int b) {
    unsigned int ua = a < 0 ? -(unsigned int)a : (unsigned int)a;
    unsigned int ub = b < 0 ? -(unsigned int)b : (unsigned int)b;
    unsigned int r;
    udivmod32(ua, ub, &r);

    return a < 0 ? (int)-r : (int)r;
}

