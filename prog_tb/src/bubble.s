.global entry
entry:
    addi a0, zero, 1024
    addi a1, zero, 0
    addi a2, zero, 0
    addi t0, zero, 0
    addi t1, zero, 0

    la   sp, stack_top
    addi sp, sp, -4

    jal print_arr

    la   a1, size
    lw   s0, (a1)

    la   a1, data

    li t0, 0
    outer:
        li t1, 1
        inner:
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

        addi t0, t0, 1
        blt  t0, s0, outer

    jal print_arr

    addi a0, zero, 1025
    sw   zero, 0(a0)

print_arr:
    addi sp, sp, -16
    sw   a1, 12(sp)
    sw   a2,  8(sp)
    sw   t0,  4(sp)
    sw   t1,  0(sp)

    la   a1, size
    lw   s0, (a1)

    la   a1, data

    addi t0, zero, 0
    show:
        slli a2, t0, 2
        add  a2, a2, a1

        lw   t1, (a2)
        sw   t1, (a0)

        addi t0, t0, 1

        blt  t0, s0, show
    
    lw   a1, 12(sp)
    lw   a2,  8(sp)
    lw   t0,  4(sp)
    lw   t1,  0(sp)

    addi sp, sp, 16

    ret

data:
    .word 5
    .word 4
    .word 3
    .word 2
    .word 1
    .word 9
    .word 10
    .word 6
    .word 8
    .word 7

size:
    .word 10

stack_bottom:
    .skip 64
stack_top:

