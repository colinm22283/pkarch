serial_addr = 0x10000000

.section .text
.global print_str
print_str:
    li   t0, serial_addr
print_str_loop:
    lb   t1, (a0)
    beq  t1, zero, print_str_exit
    sb   t1, (t0)
    addi a0, a0, 1
    j print_str_loop
print_str_exit:
    ret

.global print_hex
print_hex:
    addi sp, sp, -10

    li   t0, serial_addr
    la   t6, hex_dict
    addi t1, sp, 8
    sb   zero, (t1)
print_hex_loop:
    addi t1, t1, -1

    andi t2, a0, 0b1111
    add  t2, t2, t6
    lb   t2, (t2)
    sb   t2, (t1)

    srli a0, a0, 4

    bgt  t1, sp, print_hex_loop
    
    addi sp, sp, -4
    sw   ra, (sp)

    addi a0, sp, 4
    call print_str

    lw   ra, (sp)

    addi sp, sp, 12
    ret

.section .rodata
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
nop
nop
nop
nop
nop
nop
nop
nop
nop

hex_dict: .string "0123456789ABCDEF"

