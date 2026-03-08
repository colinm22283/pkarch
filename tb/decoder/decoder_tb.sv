`timescale 1ns/100ps

module decoder_tb();

    wire clk, nrst;
    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    initial begin
        clk_rst.RESET();

        #10000;
        $finish;
    end

endmodule

