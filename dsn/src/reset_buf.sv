module reset_buf_m(
    input  logic clk_i,

    input  logic nrst_i,
    output logic nrst_o
);

    always @(posedge clk_i) begin
        nrst_o <= nrst_i;
    end

endmodule
