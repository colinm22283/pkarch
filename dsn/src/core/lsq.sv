`include "core/lsq.svh"

module lsq_m(
    input wire clk_i,
    input wire nrst_i,

    input  lsq_dispatch_i_t dispatch_i,
    output lsq_dispatch_o_t dispatch_o
);

    lsq_entry_t [LSQ_SIZE - 1:0] entries;

    always_ff @(posedge clk_i) begin
    end



endmodule

