.global main
main:
    li s0, 0x10000000

    li t0, 10
    sw t0, (sp)
    lw t1, (sp)
    sw t1, (s0)

    sw t1, (sp)
    lw t2, (sp)
    sw t2, (s0)

    sw t2, (sp)
    lw t3, (sp)
    sw t3, (s0)

    sw t3, (sp)
    lw t4, (sp)
    sw t4, (s0)

    sw t4, (sp)
    lw t5, (sp)
    sw t5, (s0)

    sw t5, (sp)
    lw t6, (sp)
    sw t6, (s0)

    li   a0, 0x10000004
    sw   zero, 0(a0)
    
