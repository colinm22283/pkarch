`timescale 1ns/100ps

module dispatch_m(
    input wire clk_i,
    input wire nrst_i,

    input  rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_dispatch_i,
    output rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_dispatch_o,

    input  rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_i,
    output rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_o,

    

