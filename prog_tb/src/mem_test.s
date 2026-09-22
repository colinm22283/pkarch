.global main
main:
    li s0, 0x10000000

    li t0, 500
    li t1, 700

    sw t0, (t1)
    lw t2, (t1)

    sw t0, (s0)
    sw t1, (s0)
    sw t2, (s0)

    li   a0, 0x10000004
    sw   zero, 0(a0)
    
