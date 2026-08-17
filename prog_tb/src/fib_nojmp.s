.global main
main:
    li a0, 0x10000000
    
    addi s0, zero, 1
    addi s1, zero, 1

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)

    addi s2, s1, 0
    add  s1, s0, s1
    addi s0, s2, 0

    sw   s0, 0(a0)
    
    li   a0, 0x10000004
    sw   zero, 0(a0)

