.global entry
entry:
    addi a0, zero, 1024

    li s0, 7 # height

    li s2, 'a' # space
    li s3, '#' # pound

    mv s1, s0

    .main_loop:
        li t0, 0
        .spaces1:
            sb s2, (a0)

            addi t0, t0, 1
            
            blt t0, s0, .spaces1

    addi a0, zero, 1025
    sw   zero, 0(a0)
    
