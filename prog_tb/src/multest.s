.global main
main:
    li a0, 0x10000000

    li s0, 8
    li s1, 4
    mul s2, s1, s0

    sw s2, (a0)
    
    li s0, 0xFFFF
    li s1, 0x10000000
    mul  s2, s1, s0
    mulhu s3, s1, s0

    sw s2, (a0)
    sw s3, (a0)

    ret
