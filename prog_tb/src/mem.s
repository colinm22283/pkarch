.global entry
entry:
    addi a0, zero, 256

    addi s1, zero, 45
    
    sb   s1, 0(a0)
    addi s1, s1, 1
    addi s1, s1, 1
    addi s1, s1, 1
    addi s1, s1, 1
    addi s1, s1, 1
    lb   s0, 0(a0)

