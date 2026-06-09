.global entry
entry:
    addi a0, zero, 1024

    addi s0, zero, 0x10
    addi s1, zero, 0x20

    j target

target:

    add  s2, s1, s0

    sw   s0, (a0)
    sw   s1, (a0)
    sw   s2, (a0)

    addi a0, zero, 1025
    sw   zero, 0(a0)
