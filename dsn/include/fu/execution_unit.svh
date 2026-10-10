`ifndef EXECUTION_UNIT_SVH
`define EXECUTION_UNIT_SVH

typedef enum logic [2:0] {
    FU_NONE,
    FU_ALU,
    FU_INTMUL,
    FU_JMP,
    FU_LSU
} fu_select_t;

`endif

