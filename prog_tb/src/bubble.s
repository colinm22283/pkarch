.global entry
entry:
    addi a0, zero, 1024

    addi a1, zero, 0
    la   a1, size
    lw   s0, (a1)

    sw   s0, (a0)

    la   a1, data

    addi t0, zero, 0

    #outer:
        #slli a2, t0, 2
        #add  a2, a2, a1

        #lw   t1, (a2)
        #sw   t1, (a0)

        #addi t2, t0, 1
        #inner:
            #slli a3, t2, 2
            #add  a3, a3, a1
            #lw   t3, (a3)

            #blt  t1, t3, inner_done

            #sw   t3, (a2)
            #sw   t1, (a3)

            #addi t2, t2, 1

            #blt t2, s0, inner

        #inner_done:

    addi t0, zero, 0
    show:
        slli a2, t0, 2
        add  a2, a2, a1

        # sw   a2, (a0)

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

