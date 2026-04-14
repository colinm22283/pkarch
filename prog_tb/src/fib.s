.global entry
entry:
    addi a0, zero, 1024
    addi s3, zero, 256
    
    addi s0, zero, 1
    addi s1, zero, 1

    .loop:
        sw   s0, 0(a0)

        addi s2, s1, 0
        add  s1, s0, s1
        addi s0, s2, 0

        blt s0, s3, .loop
        
    addi a0, zero, 1025
    sw   zero, 0(a0)

