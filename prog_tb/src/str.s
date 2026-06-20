.global entry
entry:
    la  s0, str
    jal print

    addi a0, zero, 1025
    sw   zero, 0(a0)

print:
    addi a0, zero, 1024

    .loop:
        lb t0, (s0)

        beq t0, zero, .exit

        sb t0, (a0)

        addi s0, s0, 1

        j .loop
    .exit:

    ret

str: .asciz "hello world!\n"

