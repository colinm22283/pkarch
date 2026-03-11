`ifndef ISA_SVH
`define ISA_SVH

typedef enum logic [4:0] {
    REG_ZERO = 5'h00,
    REG_RA   = 5'h01,
    REG_SP   = 5'h02,
    REG_GP   = 5'h03,
    REG_TP   = 5'h04,
    REG_T0   = 5'h05,
    REG_T1   = 5'h06,
    REG_T2   = 5'h07,
    REG_S0   = 5'h08,
    REG_S1   = 5'h09,
    REG_A0   = 5'h0A,
    REG_A1   = 5'h0B,
    REG_A2   = 5'h0C,
    REG_A3   = 5'h0D,
    REG_A4   = 5'h0E,
    REG_A5   = 5'h0F,
    REG_A6   = 5'h10,
    REG_A7   = 5'h11,
    REG_S2   = 5'h12,
    REG_S3   = 5'h13,
    REG_S4   = 5'h14,
    REG_S5   = 5'h15,
    REG_S6   = 5'h16,
    REG_S7   = 5'h17,
    REG_S8   = 5'h18,
    REG_S9   = 5'h19,
    REG_S10  = 5'h1A,
    REG_S11  = 5'h1B,
    REG_T3   = 5'h1C,
    REG_T4   = 5'h1D,
    REG_T5   = 5'h1E,
    REG_T6   = 5'h1F,

    REG_ERROR = 5'hxx
} reg_t;

typedef logic [21:0] imm_t;

parameter IMM_ERROR = 22'hXXXXXX;

typedef struct packed {
    union packed {
        struct packed {
            bit [6:0] funct;
            reg_t rs2;
            reg_t rs1;
            bit [2:0] funct3;
            reg_t rd;
        } r;

        struct packed {
            bit [11:0] imm0;
            reg_t rs1;
            bit [2:0] funct3;
            reg_t rd;
        } i;

        struct packed {
            bit [6:0] imm1;
            reg_t rs1;
            reg_t rs2;
            bit [2:0] funct3;
            reg [4:0] imm0;
        } s;

        struct packed {
            bit [0:0] imm3;
            bit [5:0] imm1;
            reg_t rs2;
            reg_t rs1;
            bit [2:0] funct3;
            bit [3:0] imm0;
            bit [0:0] imm2;
        } b;

        struct packed {
            bit [31:12] imm0;
            reg_t rd;
        } u;

        struct packed {
            bit [0:0] imm3;
            bit [9:0] imm0;
            bit [0:0] imm1;
            bit [7:0] imm2;
            reg_t rd;
        } j;
    } t;
    bit [6:0] opcode;
} inst_t;

typedef struct packed {
    reg_t rs1, rs2, rd;
    imm_t imm;
} dec_inst_t;

`endif

