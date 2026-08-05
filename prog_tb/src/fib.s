.global entry
entry:
    li a0, 4096
    addi s3, zero, 0
    li   s3, 10000

    addi s0, zero, 1
    addi s1, zero, 1

    .loop:
        sw   s0, 0(a0)

        addi s2, s1, 0
        add  s1, s0, s1
        addi s0, s2, 0

        blt s0, s3, .loop
    
    li   a0, 4097
    sw   zero, 0(a0)

