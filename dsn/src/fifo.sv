module fifo_m #(
    parameter WIDTH = 32,
    parameter DEPTH = 4
) (
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    output logic               in_ready_o,
    input  logic               in_valid_i,
    input  logic [WIDTH - 1:0] in_data_i,

    input  logic               out_ready_i,
    output logic               out_valid_o,
    output logic [WIDTH - 1:0] out_data_o
);

    localparam INDEX_WIDTH = $clog2(DEPTH);
    localparam SIZE_WIDTH = $clog2(DEPTH + 1);

    logic [INDEX_WIDTH - 1:0] head_q, tail_d;
    logic                     head_wrap_q, head_wrap_d;
    logic [INDEX_WIDTH - 1:0] tail_q, head_d;
    logic                     tail_wrap_q, tail_wrap_d;

    logic [WIDTH - 1:0] data_q [DEPTH - 1:0];
    logic [WIDTH - 1:0] data_d [DEPTH - 1:0];

    logic empty, full;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head_q      <= '0;
            head_wrap_q <= '0;
            tail_q      <= '0;
            tail_wrap_q <= '0;
        end
        else begin
            data_q      <= data_d;
            head_q      <= head_d;
            head_wrap_q <= head_wrap_d;
            tail_q      <= tail_d;
            tail_wrap_q <= tail_wrap_d;
        end
    end

    always_comb begin
        data_d      = data_q;
        head_d      = head_q;
        head_wrap_d = head_wrap_q;
        tail_d      = tail_q;
        tail_wrap_d = tail_wrap_q;

        empty = head_d == tail_d && head_wrap_d == tail_wrap_d;
        full  = head_d == tail_d && head_wrap_d != tail_wrap_d;

        out_valid_o = 1'b0;
        in_ready_o  = 1'b0;
        out_data_o  = '0;

        if (flush_i) begin
            head_d      = '0;
            head_wrap_d = '0;
            tail_d      = '0;
            tail_wrap_d = '0;
        end
        else begin
            out_data_o  = data_q[tail_q];

            if (!empty) out_valid_o = 1'b1;
            if (!full)  in_ready_o  = 1'b1;

            if (out_ready_i && !empty) begin
                if (tail_q == INDEX_WIDTH'(DEPTH - 1)) tail_wrap_d = !tail_wrap_q;
                tail_d = INDEX_WIDTH'((tail_q + INDEX_WIDTH'(1)) % SIZE_WIDTH'(DEPTH));
            end

            if (in_valid_i && !full) begin
                data_d[head_q] = in_data_i;

                if (head_q == INDEX_WIDTH'(DEPTH - 1)) head_wrap_d = !head_wrap_q;
                head_d = INDEX_WIDTH'((head_q + INDEX_WIDTH'(1)) % SIZE_WIDTH'(DEPTH));
            end
        end
    end

endmodule
