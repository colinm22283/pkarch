`include "config.svh"
`include "core/lsq.svh"

module lsq_timestamper_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  lsq_dispatch_i_t [LSQ_READ_DISPATCH_WIDTH - 1:0] read_dispatch_i,
    output lsq_dispatch_o_t [LSQ_READ_DISPATCH_WIDTH - 1:0] read_dispatch_o,

    input  lsq_dispatch_i_t [LSQ_WRITE_DISPATCH_WIDTH - 1:0] write_dispatch_i,
    output lsq_dispatch_o_t [LSQ_WRITE_DISPATCH_WIDTH - 1:0] write_dispatch_o,

    input  logic           [LSQ_READ_DISPATCH_WIDTH - 1:0] read_ready_i,
    output logic           [LSQ_READ_DISPATCH_WIDTH - 1:0] read_valid_o,
    output lsq_timestamp_t [LSQ_READ_DISPATCH_WIDTH - 1:0] read_timestamp_o,

    input  logic           [LSQ_WRITE_DISPATCH_WIDTH - 1:0] write_ready_i,
    output logic           [LSQ_WRITE_DISPATCH_WIDTH - 1:0] write_valid_o,
    output lsq_timestamp_t [LSQ_WRITE_DISPATCH_WIDTH - 1:0] write_timestamp_o
);

    lsq_timestamp_t current_timestamp_q, current_timestamp_d

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            current_timestamp_q <= '0;
        end
        else begin
            current_timestamp_q <= current_timestamp_d;
        end
    end

    always_comb begin
        current_timestamp_d = current_timestamp_q;

        for (int i = 0; i < LSQ_READ_DISPATCH_WIDTH; i++) begin
            read_valid_o[i]              = read_dispatch_i[i].valid;
            read_dispatch_o[i].ready     = read_ready_i[i];
            read_dispatch_o[i].timestamp = current_timestamp_d;
            read_timestamp_o[i]          = current_timestamp_d;

            current_timestamp_d++;
        end

        for (int i = 0; i < LSQ_WRITE_DISPATCH_WIDTH; i++) begin
            write_valid_o[i]              = write_dispatch_i[i].valid;
            write_dispatch_o[i].ready     = write_ready_i[i];
            write_dispatch_o[i].timestamp = current_timestamp_d;
            write_timestamp_o[i]          = current_timestamp_d;

            current_timestamp_d++;
        end
    end

endmodule

