.global main
main:
    li t0, 0
    li t1, 10000

loop:
    addi t0, t0, 1
    blt  t0, t1, loop

    ret
