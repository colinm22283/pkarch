`ifndef EXECUTION_UNIT_SVH
`define EXECUTION_UNIT_SVH

typedef enum logic [1:0] {
    FU_NONE,
    FU_ALU,
    FU_JMP,
    FU_LSU
} fu_select_t;

`endif

