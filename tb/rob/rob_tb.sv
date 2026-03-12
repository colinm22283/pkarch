`timescale 1ns/100ps

`include "isa.svh"

module rob_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    rob_dispatch_i_t [1:0] dispi;
    rob_dispatch_o_t [1:0] dispo;

    rob_m dut(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(dispi),
        .dispatch_o(dispo)
    );

    initial begin
        #1000;

        $finish;
    end

endmodule

