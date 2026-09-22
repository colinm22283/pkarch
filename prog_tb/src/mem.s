.global entry
entry:
    addi a0, zero, 1024

    la t0, mem

    sw t1, (a0)
    lw t1, (t0)

    addi a0, zero, 1025
    sw   zero, 0(a0)

.global mem
mem:
    .word 32

