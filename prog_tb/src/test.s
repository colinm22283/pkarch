.global main
main:
    li a0, 0x10000000

    li t0, 2
    li t1, 3

    add t2, t0, t0
    add t3, t0, t1

    add t3, t3, t1
    add t4, t0, t1
    add t5, t4, t4

    sw   t0, (a0)
    sw   t1, (a0)
    sw   t2, (a0)
    sw   t3, (a0)
    sw   t4, (a0)
    sw   t5, (a0)

    li   s0, 0x100

    sw   t0, (s0)
    sw   t1, (s0)
    sw   t2, (s0)
    sw   t3, (s0)
    sw   t4, (s0)
    sw   t5, (s0)

    lw   t6, (s0)
    sw   t6, (a0)

    li   a0, 0x10000004
    sw   zero, 0(a0)
    
