`timescale 1ns/100ps

`include "config.svh"
`include "core/lsq.svh"

module lsq_read_queue_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  logic valid_i,
    output logic ready_o,
    input  rob_id_t rob_id_i,

    input  lsq_commit_i_t [LSU_COUNT - 1:0] commit_i,
    output lsq_commit_o_t [LSU_COUNT - 1:0] commit_o,

    input  logic                               has_write_i,
    output [$clog2(LSQ_READ_QUEUE_SIZE) - 1:0] read_head_o,
    input  [$clog2(LSQ_READ_QUEUE_SIZE) - 1:0] await_head_i,

    input  logic      load_ready_i,
    output logic      load_valid_o,
    output bus_size_t size_o,
    output word_t     addr_o,
    output reg_addr_t isa_addr_o,
    output prf_addr_t rd_o,
    output prf_addr_t prev_rd_o,
    output rob_id_t   rob_id_o
);

    localparam INDEX_WIDTH = $clog2(LSQ_READ_QUEUE_SIZE);
    localparam SIZE_WIDTH = $clog2(LSQ_READ_QUEUE_SIZE + 1);

    logic [INDEX_WIDTH - 1:0] head_q, head_d;
    logic [INDEX_WIDTH - 1:0] tail_q, tail_d;
    logic [SIZE_WIDTH - 1:0]  size_q, size_d;
    lsq_read_entry_t          entries_q [LSQ_READ_QUEUE_SIZE - 1:0];
    lsq_read_entry_t          entries_d [LSQ_READ_QUEUE_SIZE - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head_q <= '0;
            tail_q <= '0;
            size_q <= '0;
            for (int i = 0; i < LSQ_READ_QUEUE_SIZE; i++) entries_q[i] <= '0;
        end
        else begin
            head_q <= head_d;
            tail_q <= tail_d;
            size_q <= size_d;
            for (int i = 0; i < LSQ_READ_QUEUE_SIZE; i++) entries_q[i] <= entries_d[i];
        end
    end

    always_comb begin
        head_d    = head_q;
        tail_d    = tail_q;
        size_d    = size_q;
        entries_d = entries_q;

        load_valid_o     = '0;

        size_o     = entries_q[tail_q].size;
        addr_o     = entries_q[tail_q].addr;
        isa_addr_o = entries_q[tail_q].isa_addr;
        rd_o       = entries_q[tail_q].rd;
        prev_rd_o  = entries_q[tail_q].prev_rd;
        rob_id_o   = entries_q[tail_q].rob_id;

        commit_o   = '0;

        if (flush_i) begin
            ready_o = 1'b0;

            head_d = '0;
            tail_d = '0;
            size_d = '0;
            for (int i = 0; i < LSQ_READ_QUEUE_SIZE; i++) entries_d[i].valid = 1'b0;
        end
        else begin
            ready_o = size_q != LSQ_READ_QUEUE_SIZE;
            if (valid_i && size_q != LSQ_READ_QUEUE_SIZE) begin
                entries_d[head_d].valid    = 1'b1;
                entries_d[head_d].complete = 1'b0;
                entries_d[head_d].rob_id   = rob_id_i;

                head_d = INDEX_WIDTH'((head_d + INDEX_WIDTH'(1)) % SIZE_WIDTH'(LSQ_READ_QUEUE_SIZE));
                size_d++;
            end

            for (int i = 0; i < LSU_COUNT; i++) begin
                if (commit_i[i].valid) begin
                    for (int j = 0; j < LSQ_READ_QUEUE_SIZE; j++) begin
                        if (entries_q[j].valid && entries_q[j].rob_id == commit_i[i].rob_id) begin
                            entries_d[j].complete = 1'b1;
                            entries_d[j].size     = commit_i[i].size;
                            entries_d[j].addr     = commit_i[i].addr;
                            entries_d[j].isa_addr = commit_i[i].data.read.isa_addr;
                            entries_d[j].rd       = commit_i[i].data.read.rd;
                            entries_d[j].prev_rd  = commit_i[i].data.read.prev_rd;

                            commit_o[i].ready = 1'b1;
                        end
                    end
                end
            end

            if (size_q != '0 && entries_q[tail_q].valid && entries_q[tail_q].complete) begin
                if (!(has_write_i && await_head_i == tail_q)) begin
                    load_valid_o     = 1'b1;

                    if (load_ready_i) begin
                        entries_d[tail_q].valid = 1'b0;
                        tail_d = INDEX_WIDTH'((tail_d + INDEX_WIDTH'(1)) % SIZE_WIDTH'(LSQ_READ_QUEUE_SIZE));
                        size_d--;
                    end
                end
            end
        end

        read_head_o = head_q;
    end

endmodule

