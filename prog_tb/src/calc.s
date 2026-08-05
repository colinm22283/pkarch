.global entry
entry:
    la   sp, stack_top

    li   a0, 4096
    call print_num

    li   t0, '\n'
    li   t1, 4096
    sw   t0, (t1)

    li   t0, 4097
    sw   zero, (t0)

print_str:
    li   t0, 4096
print_str_loop:
    lb   t1, (a0)
    beq  t1, zero, print_str_exit
    sb   t1, (t0)
    addi a0, a0, 1
    j print_str_loop
print_str_exit:
    ret

print_num:
    addi sp, sp, -10

    li   t0, 4096
    la   t6, hex_dict
    addi t1, sp, 8
    sb   zero, (t1)
print_num_loop:
    addi t1, t1, -1

    andi t2, a0, 0b1111
    add  t2, t2, t6
    lb   t2, (t2)
    sb   t2, (t1)

    srli a0, a0, 4

    bgt  t1, sp, print_num_loop
    
    addi sp, sp, -4
    sw   ra, (sp)

    addi a0, sp, 4
    call print_str

    lw   ra, (sp)

    addi sp, sp, 12
    ret

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop

str: .asciz "hello world\n"

hex_dict: .string "0123456789ABCDEF"

stack_bottom:
    .skip 64
stack_top:

