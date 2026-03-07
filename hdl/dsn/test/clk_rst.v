module clk_rst_m #(
  parameter CLK_PER = 20,
  parameter RESET_PER = 30
) (
  output reg clk_o,
  output reg nrst_o
);

  integer current_cycle;

  initial begin
    RESET();
  end

  initial forever begin
    clk_o = 0;
    #(CLK_PER / 2);
    clk_o = 1;
    #(CLK_PER / 2);

    current_cycle = current_cycle + 1;
  end

  task RESET;
  begin
    current_cycle = 0;

    nrst_o = 0;
    #RESET_PER;
    nrst_o = 1;
  end
  endtask

  task WAIT_CYCLES;
    input integer cycles;

    integer i;
  begin
    for (i = 0; i < cycles; i = i + 1) begin
      wait(clk_o);
      wait(!clk_o);
    end
  end
  endtask

endmodule

