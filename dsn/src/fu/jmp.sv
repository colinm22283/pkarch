module jmp_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  iq_commit_o_t dispatch_i,
    output iq_commit_i_t dispatch_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);
endmodule

