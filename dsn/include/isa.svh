`ifndef ISA_SVH
`define ISA_SVH

parameter REG_COUNT = 32;
parameter REG_ADDR_WIDTH = $clog2(REG_COUNT);

typedef enum logic [REG_ADDR_WIDTH - 1:0] {
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
} reg_addr_t;

typedef logic [31:0] imm_t;

parameter IMM_ERROR = 32'hXXXXXX;

typedef logic [6:0] opcode_t;

typedef struct packed {
    union packed {
        struct packed {
            bit [6:0] funct7;
            reg_addr_t rs2;
            reg_addr_t rs1;
            bit [2:0] funct3;
            reg_addr_t rd;
        } r;

        struct packed {
            bit [11:0] imm0;
            reg_addr_t rs1;
            bit [2:0] funct3;
            reg_addr_t rd;
        } i;

        struct packed {
            bit [6:0] imm1;
            reg_addr_t rs1;
            reg_addr_t rs2;
            bit [2:0] funct3;
            reg [4:0] imm0;
        } s;

        struct packed {
            bit [0:0] imm3;
            bit [5:0] imm1;
            reg_addr_t rs2;
            reg_addr_t rs1;
            bit [2:0] funct3;
            bit [3:0] imm0;
            bit [0:0] imm2;
        } b;

        struct packed {
            bit [31:12] imm0;
            reg_addr_t rd;
        } u;

        struct packed {
            bit [0:0] imm3;
            bit [9:0] imm0;
            bit [0:0] imm1;
            bit [7:0] imm2;
            reg_addr_t rd;
        } j;
    } t;
    opcode_t opcode;
} inst_t;

`define FUNCT_CONCAT(f3, f7) ({ (f3), (f7) })

typedef logic [9:0] funct_t;

parameter FUNCT_ADD  = (`FUNCT_CONCAT(3'h0, 7'h00));
parameter FUNCT_SUB  = (`FUNCT_CONCAT(3'h0, 7'h20));
parameter FUNCT_XOR  = (`FUNCT_CONCAT(3'h4, 7'h00));
parameter FUNCT_OR   = (`FUNCT_CONCAT(3'h6, 7'h00));
parameter FUNCT_AND  = (`FUNCT_CONCAT(3'h7, 7'h00));
parameter FUNCT_SLL  = (`FUNCT_CONCAT(3'h1, 7'h00));
parameter FUNCT_SRL  = (`FUNCT_CONCAT(3'h5, 7'h20));
parameter FUNCT_SRA  = (`FUNCT_CONCAT(3'h5, 7'h00));
parameter FUNCT_SLT  = (`FUNCT_CONCAT(3'h2, 7'h00));
parameter FUNCT_SLTU = (`FUNCT_CONCAT(3'h3, 7'h00));

typedef struct packed {
    bit rs1_a, rs2_a, rd_a;
    reg_addr_t rs1, rs2, rd;
    imm_t imm;

    funct_t funct;

    opcode_t opcode;
} dec_inst_t;

`endif

