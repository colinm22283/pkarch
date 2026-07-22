module fifo_m #(
    parameter WIDTH = 32,
    parameter DEPTH = 4
) (
    input  logic clk_i,
    input  logic nrst_i,

    output logic               in_ready_o,
    input  logic               in_valid_i,
    input  logic [WIDTH - 1:0] in_data_i,

    input  logic               out_ready_i,
    output logic               out_valid_o,
    output logic [WIDTH - 1:0] out_data_o
);

    localparam INDEX_WIDTH = $clog2(DEPTH);
    localparam SIZE_WIDTH  = $clog2(DEPTH + 1);

    logic push, pop;

    logic [INDEX_WIDTH - 1:0] head, tail;
    logic [SIZE_WIDTH - 1:0]  size;

    logic [WIDTH - 1:0] data [DEPTH - 1:0]

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head <= 0;
            tail <= 0;
            size <= 0;
        end
        else begin
            if (push && pop) begin
                head <= head + 1;
                tail <= tail + 1;
            end
            else if (push) begin
                head <= head + 1;
                size <= size + 1;
            end
            else if (pop) begin
                tail <= tail + 1;
                size <= size - 1;
            end
        end
    end

    always_comb begin
        in_ready_o  = size != DEPTH;
        out_valid_o = size != 0;

        out_data_o  = data[tail];

        push = in_ready_o && in_valid_i;
        pop  = out_ready_i && out_valid_o;
    end

endmodule
