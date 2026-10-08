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

    logic [WIDTH - 1:0] ands    [WIDTH - 1:0];
    logic [WIDTH - 1:0] sums    [WIDTH - 2:0];
    logic [WIDTH - 2:0] carries [WIDTH - 2:0];
    logic [WIDTH - 1:0] out_sums;
    logic [WIDTH - 1:0] out_carries;
    logic [WIDTH:0]     final_carries;

    generate
        for (genvar i = 0; i < WIDTH - 1; i++) begin
            logic b;

            assign b = in_data1_i[i];
            always_comb for (int j = 0; j < WIDTH; j++) begin
                if (j == WIDTH - 1) begin
                    ands[i][j] = in_data0_i[j] & ~b;
                end
                else begin
                    ands[i][j] = in_data0_i[j] & b;
                end
            end

            for (genvar j = 0; j < WIDTH - 1; j++) begin
                if (i == 0) begin
                    assign sums[i][j]    = ands[i][j];
                    assign carries[i][j] = '0;
                end
                else begin
                    full_adder_m fa(
                        .a_i(sums[i - 1][j + 1]),
                        .b_i(carries[i - 1][j]),
                        .c_i(ands[i][j]),
                        .y_o(sums[i][j]),
                        .c_o(carries[i][j])
                    );
                end
            end

            assign sums[i][WIDTH - 1] = ands[i][WIDTH - 1];
        end

        for (genvar i = 0; i < WIDTH - 1; i++) begin
            assign out_data_o[i] = sums[i][0];
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            logic b;

            assign b = in_data1_i[WIDTH - 1];

            if (i == WIDTH - 1) begin
                assign ands[WIDTH - 1][i] = in_data0_i[i] & b;
            end
            else begin
                assign ands[WIDTH - 1][i] = in_data0_i[i] & ~b;
            end

            if (i == WIDTH - 1) begin
                full_adder_m fa(
                    .a_i(~in_data0_i[WIDTH - 1]),
                    .b_i(~b),
                    .c_i(ands[WIDTH - 1][i]),
                    .y_o(out_sums[i]),
                    .c_o(out_carries[i])
                );
            end
            else begin
                full_adder_m fa(
                    .a_i(sums[WIDTH - 2][i + 1]),
                    .b_i(carries[WIDTH - 2][i]),
                    .c_i(ands[WIDTH - 1][i]),
                    .y_o(out_sums[i]),
                    .c_o(out_carries[i])
                );
            end
        end
    endgenerate

    generate
        full_adder_m fa(
            .a_i(out_sums[0]),
            .b_i(in_data0_i[WIDTH - 1]),
            .c_i(in_data1_i[WIDTH - 1]),
            .y_o(out_data_o[WIDTH - 1]),
            .c_o(final_carries[0])
        );

        for (genvar i = 0; i < WIDTH; i++) begin
            full_adder_m fa(
                .a_i(i == WIDTH - 1 ? 1'b1 : out_sums[i + 1]),
                .b_i(out_carries[i]),
                .c_i(final_carries[i]),
                .y_o(out_data_o[WIDTH + i]),
                .c_o(final_carries[i + 1])
            );
        end
    endgenerate

    assign out_valid_o = in_valid_i;
    assign in_ready_o  = out_ready_i;

endmodule

