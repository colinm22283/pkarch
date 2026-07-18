.global entry
entry:
    addi a0, zero, 1024

    la t0, mem

    lw t1, (t0)
    sw t1, (a0)

    addi a0, zero, 1025
    sw   zero, 0(a0)

.global mem
mem:
    .word 32

