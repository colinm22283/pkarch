.global entry
entry:
    addi a0, zero, 1024
    
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
        
    addi a0, zero, 1025
    sw   zero, 0(a0)

