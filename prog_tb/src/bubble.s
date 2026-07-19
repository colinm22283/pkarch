.global entry
entry:
    addi a0, zero, 1024

    addi a1, zero, 0
    la   a1, size
    lw   s0, (a1)

    la   a1, data

    li t0, 0
    outer:
        li t1, 1
        inner:
            sw   t1, (a0)

            slli t2, t1, 2
            add  t2, t2, a1
            lw   t3, (t2)
            lw   t4, -4(t2)

            blt t4, t3, noswap
                sw   t3, -4(t2)
                sw   t4, (t2)
            noswap:

            addi t1, t1, 1
            blt  t1, s0, inner

        sw t0, (a0)

        addi t0, t0, 1
        blt  t0, s0, outer

    la   a1, data

    addi t0, zero, 0
    show:
        slli a2, t0, 2
        add  a2, a2, a1

        lw   t1, (a2)
        sw   t1, (a0)

        addi t0, t0, 1

        blt  t0, s0, show

    addi a0, zero, 1025
    sw   zero, 0(a0)

.global data
data:
    .word 5
    .word 4
    .word 3
    .word 2
    .word 1

.global size
size:
    .word 5

