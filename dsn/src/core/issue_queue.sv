`include "config.svh"
`include "core/dispatch.svh"

module issue_queue_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  dispatch_i_t [DISPATCH_WIDTH - 1:0] sdispatch_i,
    output dispatch_o_t [DISPATCH_WIDTH - 1:0] sdispatch_o,

    input  dispatch_o_t [DISPATCH_WIDTH - 1:0] mdispatch_i,
    output dispatch_i_t [DISPATCH_WIDTH - 1:0] mdispatch_o
);

    localparam SIZE_WIDTH = $clog2(ISSUE_QUEUE_SIZE + 1);
    localparam INDEX_WIDTH = $clog2(ISSUE_QUEUE_SIZE);

    typedef struct packed {
        bit valid;
        pc_t pc;
        dec_inst_t dec_inst;
    } [DISPATCH_WIDTH - 1:0] entry_t;

    logic push, pop;

    logic [SIZE_WIDTH - 1:0] size;
    entry_t entries [ISSUE_QUEUE_SIZE - 1:0];

    always_comb begin
        push = 0;
        for (int i = 0; i < DISPATCH_WIDTH; i++) push |= sdispatch_i[i].valid;

        push &= size != ISSUE_QUEUE_SIZE;
    end

    always_comb begin
        pop = 1;
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            if (entries[0][i].valid) pop &= mdispatch_i[i].ready;
        end

        pop &= size != 0;
    end

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            size <= 0;
        end
        else begin
            if (flush_i) begin
                size <= 0;
            end
            else begin
                logic [SIZE_WIDTH - 1:0] t_size;
                entry_t t_entries [ISSUE_QUEUE_SIZE - 1:0];

                t_size = size;
                t_entries = entries;

                if (push) begin
                    for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                        t_entries[INDEX_WIDTH'(size)][i].valid    = sdispatch_i[i].valid;
                        t_entries[INDEX_WIDTH'(size)][i].pc       = sdispatch_i[i].pc;
                        t_entries[INDEX_WIDTH'(size)][i].dec_inst = sdispatch_i[i].dec_inst;
                    end

                    t_size = t_size + 1;
                end
                
                if (pop) begin
                    for (int i = 0; i < ISSUE_QUEUE_SIZE - 1; i++) begin
                        t_entries[i] = t_entries[i + 1];
                    end

                    t_size = t_size - 1;
                end

                size    <= t_size;
                entries <= t_entries;
            end
        end
    end

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            sdispatch_o[i].ready = push;
        end

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            mdispatch_o[i].valid    = pop && entries[0][i].valid;
            mdispatch_o[i].pc       = entries[0][i].pc;
            mdispatch_o[i].dec_inst = entries[0][i].dec_inst;
        end
    end

endmodule

