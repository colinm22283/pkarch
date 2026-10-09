module mult_m #(
    parameter integer WIDTH = 32,
    parameter logic [WIDTH - 1:0] STAGES = '0
) (
    input  logic clk_i,
    input  logic nrst_i,

    input  logic valid_i,
    output logic ready_o,
    input  logic [WIDTH - 1:0] a_i,
    input  logic [WIDTH - 1:0] b_i,

    output logic valid_o,
    input  logic ready_i,
    output logic [2 * WIDTH - 1:0] y_o
);

    logic [WIDTH:0] stage_in_valid;
    logic [WIDTH:0] stage_in_ready;

    assign stage_in_valid[0] = valid_i;
    assign ready_o           = stage_in_ready[0];

    assign valid_o               = stage_in_valid[WIDTH];
    assign stage_in_ready[WIDTH] = ready_i;

    generate
        for (genvar i = 0; i < WIDTH; i++) begin : MULT_STAGE
            logic [WIDTH + i - 1:0] stage_in;
            logic [WIDTH + i:0]     stage_out;

            logic [2 * WIDTH - i - 1:0] add_a, add_b;
            logic [2 * WIDTH - i:0]     add_y;

            if (i == 0) begin
                assign stage_in = '0;
            end
            else begin
                assign stage_in = MULT_STAGE[i - 1].stage_out;
            end

            assign add_y = add_a + add_b;

            assign add_a = stage_in[2 * WIDTH - i - 1:0];
            assign add_b = 
        end
    endgenerate

endmodule

