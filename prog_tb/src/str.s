.global entry
entry:
    addi s0, zero, %lo(str)
    jal print

    addi a0, zero, 1025
    sw   zero, 0(a0)

print:
    addi a0, zero, 1024

    .loop:
        lb t0, (s0)
        sb t0, (a0)

        addi t0, t0, 1

        bne s0, zero, .loop

    ret

str: .asciz "hello world!\n"

