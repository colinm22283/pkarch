.global main
main:
    li s0, 0x10000000

    li t0, 500
    srai t1, t0, 31
    srli t2, t1, 28
    add  t3, t0, t2

    sw   t0, (s0)
    sw   t1, (s0)
    sw   t2, (s0)
    sw   t3, (s0)

    li   a0, 0x10000004
    sw   zero, 0(a0)
    
