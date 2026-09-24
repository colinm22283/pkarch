`timescale 1ns/100ps

`include "config.svh"
`include "core/lsq.svh"

module lsq_write_queue_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  logic valid_i,
    output logic ready_o,
    input  rob_id_t rob_id_i,

    input  lsq_commit_i_t [LSU_COUNT - 1:0] commit_i,
    output lsq_commit_o_t [LSU_COUNT - 1:0] commit_o,

    input  commit_o_t [LSU_COUNT - 1:0] write_commit_i,
    output commit_i_t [LSU_COUNT - 1:0] write_commit_o,

    input  logic rob_write_valid_i,
    output logic rob_write_ready_o,

    output logic                               has_write_o,
    input  [$clog2(LSQ_READ_QUEUE_SIZE) - 1:0] read_head_i,
    output [$clog2(LSQ_READ_QUEUE_SIZE) - 1:0] await_head_o,

    input  logic      store_ready_i,
    output logic      store_valid_o,
    output bus_size_t size_o,
    output word_t     addr_o,
    output word_t     value_o
);

    localparam INDEX_WIDTH = $clog2(LSQ_WRITE_QUEUE_SIZE);
    localparam SIZE_WIDTH = $clog2(LSQ_WRITE_QUEUE_SIZE + 1);

    logic [INDEX_WIDTH - 1:0] head_q, head_d;
    logic [INDEX_WIDTH - 1:0] tail_q, tail_d;
    logic [SIZE_WIDTH - 1:0]  size_q, size_d;
    lsq_write_entry_t         entries_q [LSQ_WRITE_QUEUE_SIZE - 1:0];
    lsq_write_entry_t         entries_d [LSQ_WRITE_QUEUE_SIZE - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head_q <= '0;
            tail_q <= '0;
            size_q <= '0;
            for (int i = 0; i < LSQ_WRITE_QUEUE_SIZE; i++) entries_q[i] <= '0;
        end
        else begin
            head_q <= head_d;
            tail_q <= tail_d;
            size_q <= size_d;
            for (int i = 0; i < LSQ_WRITE_QUEUE_SIZE; i++) entries_q[i] <= entries_d[i];
        end
    end

    always_comb begin
        head_d    = head_q;
        tail_d    = tail_q;
        size_d    = size_q;
        entries_d = entries_q;

        store_valid_o     = '0;
        rob_write_ready_o = '0;

        has_write_o = '0;

        size_o = entries_q[tail_q].size;
        addr_o = entries_q[tail_q].addr;
        value_o = entries_q[tail_q].value;

        commit_o   = '0;

        await_head_o = entries_q[tail_q].read_idx;

        write_commit_o = '0;
        for (int i = 0; i < LSU_COUNT; i++) write_commit_o[i].mem = 1'b1;

        if (flush_i) begin
            ready_o = 1'b0;

            head_d = '0;
            tail_d = '0;
            size_d = '0;
            for (int i = 0; i < LSQ_WRITE_QUEUE_SIZE; i++) entries_d[i].valid = 1'b0;
        end
        else begin
            ready_o = size_q != LSQ_WRITE_QUEUE_SIZE;
            if (valid_i && size_q != LSQ_WRITE_QUEUE_SIZE) begin
                entries_d[head_d].valid    = 1'b1;
                entries_d[head_d].complete = 1'b0;
                entries_d[head_d].rob_id   = rob_id_i;
                entries_d[head_d].read_idx = read_head_i;

                head_d = INDEX_WIDTH'((head_d + INDEX_WIDTH'(1)) % SIZE_WIDTH'(LSQ_READ_QUEUE_SIZE));
                size_d++;
            end

            for (int i = 0; i < LSU_COUNT; i++) begin
                if (commit_i[i].valid && write_commit_i[i].ready) begin
                    for (int j = 0; j < LSQ_WRITE_QUEUE_SIZE; j++) begin
                        if (entries_q[j].valid && entries_q[j].rob_id == commit_i[i].rob_id) begin
                            write_commit_o[i].valid = 1'b1;
                            write_commit_o[i].rob_id = commit_i[i].rob_id;

                            entries_d[j].complete = 1'b1;
                            entries_d[j].size     = commit_i[i].size;
                            entries_d[j].addr     = commit_i[i].addr;
                            entries_d[j].value    = commit_i[i].data.write.value;

                            commit_o[i].ready = 1'b1;
                        end
                    end
                end
            end

            if (size_q != '0 && entries_q[tail_q].valid && entries_q[tail_q].complete) begin
                store_valid_o     = rob_write_valid_i;
                rob_write_ready_o = store_ready_i;

                if (store_ready_i && rob_write_valid_i) begin
                    tail_d = INDEX_WIDTH'((tail_d + INDEX_WIDTH'(1)) % SIZE_WIDTH'(LSQ_READ_QUEUE_SIZE));
                    size_d--;
                end
            end

            has_write_o = size_q != 0;
        end
    end

endmodule

