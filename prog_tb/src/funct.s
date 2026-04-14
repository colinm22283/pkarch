.global entry
entry:
    addi a0, zero, 1024

    addi s0, zero, 10
    sb s0, (a0)
    
    jal function

    addi s0, zero, 12
    sb s0, (a0)

    addi a0, zero, 1025
    sw   zero, 0(a0)

function:
    addi s0, zero, 11
    sb s0, (a0)

    ret

