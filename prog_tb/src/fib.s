.global main
main:
    li a0, 0x10000000
    li t0, 0x00000000
    li t1, 0x00000100

    addi s0, zero, 1
    addi s1, zero, 1

    .loop:
        sw   s0, 0(a0)

        addi s2, s1, 0
        add  s1, s0, s1
        addi s0, s2, 0

        addi t0, t0, 1

        blt t0, t1, .loop
    
    li   a0, 0x10000004
    sw   zero, 0(a0)

