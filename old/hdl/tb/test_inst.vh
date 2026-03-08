//add x1, x2, x3
`define TEST_ADD_INST 32'h003100b3
//addi x1 , x0,   1000
`define TEST_ADDI_INST 32'h3e800093
//mul x1, x2, x3
`define TEST_MUL_INST 32'h023100b3
//mulh x1, x2, x3
`define TEST_MULH_INST 32'h023110b3
//div x1, x2, x3
`define TEST_DIV_INST 32'h023140b3
//rem x1, x3, x3
`define TEST_REM_INST 32'h0231e0b3
// sub x2, x3, x4
`define TEST_SUB_INST 32'h40418133
// xor x3, x4, x5
`define TEST_XOR_INST 32'h005241b3
// or x4, x5, x6
`define TEST_OR_INST 32'h0062e233
// and x5, x6, x7
`define TEST_AND_INST 32'h007372b3
// sll x1, x2, x2
`define TEST_SLL_INST 32'h002110b3
// srl x2, x2, x2
`define TEST_SRL_INST 32'h00215133
// sra x3, x3, x3
`define TEST_SRA_INST 32'h4031d1b3
// slt x7, x7, x7
`define TEST_SLT_INST 32'h0073a3b3
//xori x3, x4, 1
`define TEST_XORI_INST 32'h00124193
//ori x4, x5, 2
`define TEST_ORI_INST 32'h0022e213
//andi x5, x6, 3
`define TEST_ANDI_INST 32'h00337293
//slli x1, x2, 4
`define TEST_SLLI_INST 32'h00411093
//srli x2, x2, 5
`define TEST_SRLI_INST 32'h00515113
//srai x3, x3, 6
`define TEST_SRAI_INST 32'h4061d193
//slti x7, x7, 7
`define TEST_SLTI_INST 32'h0073a393
//lb x1, 1000(x0)
`define TEST_LB_INST 32'h3e800083
//lw x2, 2000(x0)
`define TEST_LW_INST 32'h7d002103
//lbu x3, 500(x0)
`define TEST_LBU_INST 32'h1f404183
//sb x4, 750(x0)
`define TEST_SB_INST 32'h2e400723
//sw x5, 0(x0)
`define TEST_SW_INST 32'h00502023
//beq x1, x2, 20
`define TEST_BEQ_INST 32'h00209463
//bne x1, x2, 20
`define TEST_BNE_INST 32'h0100006f
//blt x1, x2, 20
`define TEST_BLT_INST 32'h00208463
//bge x1, x2, 20
`define TEST_BGE_INST 32'h0080006f
//bltu x1, x2, 20
`define TEST_BLTU_INST 32'h0020d463
//bgeu x1, x2, 20
`define TEST_BGEU_INST 32'h0000006f
//jal x3, 40
`define TEST_JAL_INST 32'h028001ef
//jalr x3, 1(x4)
`define TEST_JALR_INST 32'h001201e7
//lui x1, 1047575
`define TEST_LUI_INST 32'hffc170b7
//auipc x2, 1000
`define TEST_AUIPC_INST 32'h003e8117
//ecall
`define TEST_ECALL_INST 32'h00000073
//ebreak
`define TEST_EBREAK_INST 32'h00100073
