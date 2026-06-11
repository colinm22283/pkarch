.global entry
entry:
    addi a0, zero, 1024

    addi s0, zero, 8
    addi s1, zero, '#'
    addi s2, zero, '\n'

    addi t0, zero, 0
    .y:
        addi t1, zero, 0

        .x:
            sb s1, (a0)

            addi t1, t1, 1

            blt t1, s0, .x

        sb s2, (a0)

        addi t0, t0, 1

        blt t0, s0, .y

    addi a0, zero, 1025
    sw   zero, 0(a0)
