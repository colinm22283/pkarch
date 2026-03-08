`timescale 1ns/100ps

module clk_rst_m #(
    parameter CLK_PER = 10,
    parameter RESET_CYCLES = 10
) (
    output reg clk_o,
    output reg nrst_o
);

    initial forever begin
        clk_o = 1;
        #(CLK_PER / 2);
        clk_o = 0;
        #(CLK_PER / 2);
    end

    task RESET;
    begin
        nrst_o = 0;
        WAIT_CYCLES(RESET_CYCLES);
        nrst_o = 1;
    end
    endtask

    task WAIT_CYCLES;
        input integer count;
    begin
        integer i;

        for (i = 0; i < count; i++) begin
            wait(clk_o);
            wait(!clk_o);
        end
    end
    endtask

endmodule

