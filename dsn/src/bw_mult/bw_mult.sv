module bw_mult_m #(
    parameter integer WIDTH = 32,
    parameter logic [WIDTH:0] STAGES = '0
) (
    input  logic clk_i,
    input  logic nrst_i,

    input  logic               in_valid_i,
    output logic               in_ready_o,
    input  logic [WIDTH - 1:0] in_data0_i,
    input  logic [WIDTH - 1:0] in_data1_i,

    output logic                   out_valid_o,
    input  logic                   out_ready_i,
    output logic [2 * WIDTH - 1:0] out_data_o
);

    assign out_valid_o = in_valid_i;
    assign in_ready_o  = out_ready_i;
    assign out_data_o  = in_data0_i * in_data1_i;

endmodule

