module bw_mult_m #(
    parameter integer WIDTH = 32,
    parameter logic [WIDTH - 1:0] STAGES = '0,
    parameter integer EXTRA_SIZE = 0
) (
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  logic               valid_i,
    output logic               ready_o,
    input  logic               a_unsigned_i,
    input  logic               b_unsigned_i,
    input  logic [WIDTH - 1:0] a_i,
    input  logic [WIDTH - 1:0] b_i,
    input  logic [EXTRA_SIZE - 1:0] extra_i,

    output logic                   valid_o,
    input  logic                   ready_i,
    output logic [2 * WIDTH - 1:0] y_o,
    output logic [EXTRA_SIZE - 1:0] extra_o
);

    logic [WIDTH - 1:0] ands_q     [WIDTH - 1:0];
    logic [WIDTH - 1:0] ands_d     [WIDTH - 1:0];
    logic [WIDTH - 1:0] sums_q     [WIDTH - 1:0];
    logic [WIDTH - 1:0] sums_d     [WIDTH - 1:0];
    logic [WIDTH - 2:0] carries_q  [WIDTH - 1:0];
    logic [WIDTH - 2:0] carries_d  [WIDTH - 1:0];
    logic [1:0]         unsigned_q [WIDTH - 1:0];
    logic [1:0]         unsigned_d [WIDTH - 1:0];

    logic [EXTRA_SIZE - 1:0] extra_q [WIDTH - 1:0];
    logic [EXTRA_SIZE - 1:0] extra_d [WIDTH - 1:0];

    logic               valid                [WIDTH:0];
    logic               ready                [WIDTH:0];

    logic [WIDTH - 1:0] final_carries;

    assign ready_o      = ready[0];
    assign ready[WIDTH] = ready_i;

    assign valid_o      = valid[WIDTH];
    assign valid[0]     = valid_i;

    assign unsigned_d[0] = { b_unsigned_i, a_unsigned_i };
    generate
        for (genvar i = 0; i < WIDTH - 1; i++) begin
            assign unsigned_d[i + 1] = unsigned_q[i];
        end
    endgenerate

    assign extra_d[0] = extra_i;
    generate
        for (genvar i = 0; i < WIDTH - 1; i++) begin
            assign extra_d[i + 1] = extra_q[i];
        end
    endgenerate
    assign extra_o = extra_q[WIDTH - 1];

    assign y_o[WIDTH - 1:0] = OUTPUT_GEN[WIDTH - 1].y_q;

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            logic valid_q, valid_d;

            if (STAGES[i]) begin
                assign ready[i]     = ready[i + 1] || !valid_q;
                assign valid[i + 1] = valid_q;

                always_comb begin
                    valid_d = valid_q;

                    if (ready[i + 1]) valid_d = 1'b0;

                    if (!valid_d && valid[i] && ready[i]) begin
                        valid_d = 1'b1;
                    end
                end

                always_ff @(posedge clk_i) begin
                    if (!nrst_i || flush_i) begin
                        valid_q <= '0;
                    end
                    else begin
                        valid_q <= valid_d;
                    end
                end
            end
            else begin
                assign ready[i]     = ready[i + 1];
                assign valid[i + 1] = valid[i];
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH; i++) begin : INPUT_GEN
            logic [WIDTH - 1:0]     a_q, a_d;
            logic [WIDTH - i - 1:0] b_q, b_d;

            if (i == 0) begin
                assign a_d = a_i;
                assign b_d = b_i;
            end
            else begin
                assign a_d = INPUT_GEN[i - 1].a_q;
                assign b_d = INPUT_GEN[i - 1].b_q[WIDTH - i:1];
            end

            if (STAGES[i]) begin
                always_ff @(posedge clk_i) begin
                    if (ready[i] && valid[i]) begin
                        a_q <= a_d;
                        b_q <= b_d;
                    end
                end
            end
            else begin
                assign a_q = a_d;
                assign b_q = b_d;
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH; i++) begin : OUTPUT_GEN
            logic [i:0]             y_q, y_d;

            if (i != 0) begin
                assign y_d[i - 1:0] = OUTPUT_GEN[i - 1].y_q;
            end

            if (STAGES[i]) begin
                always_ff @(posedge clk_i) begin
                    if (ready[i] && valid[i]) begin
                        y_q <= y_d;
                    end
                end
            end
            else begin
                assign y_q = y_d;
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            if (STAGES[i]) begin
                always_ff @(posedge clk_i) begin
                    if (ready[i] && valid[i]) begin
                        ands_q[i]     <= ands_d[i];
                        sums_q[i]     <= sums_d[i];
                        carries_q[i]  <= carries_d[i];
                        unsigned_q[i] <= unsigned_d[i];

                        extra_q[i] <= extra_d[i];
                    end
                end
            end
            else begin
                assign ands_q[i]     = ands_d[i];
                assign sums_q[i]     = sums_d[i];
                assign carries_q[i]  = carries_d[i];
                assign unsigned_q[i] = unsigned_d[i];

                assign extra_q[i] = extra_d[i];
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            logic b;

            assign b = INPUT_GEN[i].b_d[0];
            always_comb for (int j = 0; j < WIDTH; j++) begin
                logic a;

                assign a = INPUT_GEN[i].a_d[j];

                if (i == WIDTH - 1) begin
                    // last b
                    if (j == WIDTH - 1) begin
                        // last a
                        if (unsigned_d[i][1]) begin
                            if (unsigned_d[i][0]) ands_d[i][j] = a & b;
                            else                  ands_d[i][j] = ~(a & b);
                        end
                        else begin
                            if (unsigned_d[i][0]) ands_d[i][j] = ~(a & b);
                            else                  ands_d[i][j] = a & b;
                        end
                    end
                    else begin
                        if (unsigned_d[i][1]) begin
                            ands_d[i][j] = a & b;
                        end
                        else begin
                            ands_d[i][j] = ~(a & b);
                        end
                    end
                end
                else begin
                    if (j == WIDTH - 1) begin
                        // last a
                        if (unsigned_d[i][0]) ands_d[i][j] = a & b;
                        else                  ands_d[i][j] = ~(a & b);
                    end
                    else begin
                        ands_d[i][j] = a & b;
                    end
                end
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            for (genvar j = 0; j < WIDTH - 1; j++) begin
                if (i == 0) begin
                    assign sums_d[i][j]    = ands_d[i][j];
                    assign carries_d[i][j] = '0;
                end
                else begin
                    full_adder_m fa(
                        .a_i(sums_q[i - 1][j + 1]),
                        .b_i(carries_q[i - 1][j]),
                        .c_i(
                            i == WIDTH - 1 && j == 0 && (^unsigned_d[i]) ? 1'b1 : ands_d[i][j]
                        ),
                        .y_o(sums_d[i][j]),
                        .c_o(carries_d[i][j])
                    );
                end
            end

            assign sums_d[i][WIDTH - 1] = ands_d[i][WIDTH - 1];
        end

        for (genvar i = 0; i < WIDTH; i++) begin
            assign OUTPUT_GEN[i].y_d[i] = sums_d[i][0];
        end
    endgenerate

    generate
        for (genvar i = 0; i < WIDTH - 1; i++) begin
            full_adder_m fa(
                .a_i(sums_q[WIDTH - 1][i + 1]),
                .b_i(carries_q[WIDTH - 1][i]),
                .c_i(final_carries[i]),
                .y_o(y_o[WIDTH + i]),
                .c_o(final_carries[i + 1])
            );
        end

        assign final_carries[0] = (&unsigned_q[WIDTH - 1]) ? 1'b0 : 1'b1;
        assign y_o[2 * WIDTH - 1] = (&unsigned_q[WIDTH - 1]) ? final_carries[WIDTH - 1] : ~final_carries[WIDTH - 1];
    endgenerate

endmodule

