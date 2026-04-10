`include "config.svh"
`include "dispatch.svh"

module issue_queue_m(
    input wire clk_i,
    input wire nrst_i,

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
    entry_t [ISSUE_QUEUE_SIZE - 1:0] entries;

    always_comb begin
        push = 0;

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            push |= sdispatch_i[i].valid;
        end
    end

    always_comb begin
        pop = 0;

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            pop |= mdispatch_i[i].ready;
        end
    end

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
        end
    end

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            size = 0;
        end
        else begin
            if (pop && push && size == 0) ;
            else if (pop && size != 0) begin
                for (int i = 0; i < ISSUE_QUEUE_SIZE - 1; i++) begin
                    entries[i] = entries[i + 1];
                end
                size = size - 1;
            end
            else if (push && size != ISSUE_QUEUE_SIZE) begin
                for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                    entries[size][i].valid = sdispatch_i[i].valid;
                end
                size = size + 1;
            end
        end
    end

    always_comb begin
        if (pop && push && size == 0) begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                sdispatch_o[i].ready = 1;

                mdispatch_o[i].valid = 1;
                mdispatch_o[i].pc = sdispatch_i[i].pc;
                mdispatch_o[i].dec_inst = sdispatch_i[i].dec_inst;
            end
        end
        else if (pop && size != 0) begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                sdispatch_o[i].ready = size != ISSUE_QUEUE_SIZE;

                mdispatch_o[i].valid = entries[0][i].valid;
                mdispatch_o[i].pc = entries[0][i].pc;
                mdispatch_o[i].dec_inst = entries[0][i].dec_inst;
            end
        end
        else begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                sdispatch_o[i].ready = 0;

                mdispatch_o[i].valid = 0;
                mdispatch_o[i].pc = 0;
                mdispatch_o[i].dec_inst = 0;
            end
        end
    end

endmodule

