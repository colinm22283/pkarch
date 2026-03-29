`timescale 1ns/100ps

`include "fu.svh"

module fu_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    res_dispatch_i_t dispatchi;
    res_dispatch_o_t dispatcho;

    commit_i_t [1:0] commiti;
    commit_o_t [1:0] commito;

    alu_m #(2) alu(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(dispatchi),
        .dispatch_o(dispatcho),

        .commit_i(commito),
        .commit_o(commiti)
    );

    initial begin
        dispatchi = 0;
        commiti   = 0;

        clk_rst.RESET();

        wait(!clk);
        dispatchi[0].valid = 1;
        dispatchi[0].dec_inst.opcode = 7'b0110011;
        wait(dispatcho[0].ready);
        wait(clk);
        #1;
        dispatchi[0].valid = 0;

        #1000;

        $finish;
    end

    initial begin
        #10000;

        $display("TIMEOUT!!!");

        $finish;
    end

endmodule

