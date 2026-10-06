`timescale 1ns/100ps

`include "core/dispatch.svh"

module fetch_expander_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  dispatch_i_t sdispatch_i,
    output dispatch_o_t sdispatch_o,

    input  dispatch_o_t [DISPATCH_WIDTH - 1:0] mdispatch_i,
    output dispatch_i_t [DISPATCH_WIDTH - 1:0] mdispatch_o
);

    generate if (DISPATCH_WIDTH == 1) begin
        assign mdispatch_o = sdispatch_i;
        assign sdispatch_o = mdispatch_i;
    end
    else begin
        logic nrst;
        reset_buf_m reset_buf(
            .clk_i(clk_i),
            .nrst_i(nrst_i),
            .nrst_o(nrst)
        );

        typedef struct packed {
            pc_t pc;
            dec_inst_t dec_inst;
        } [DISPATCH_WIDTH - 1:0] entry_t;
        
        logic mready;

        logic [$clog2(DISPATCH_WIDTH + 1) - 1:0] size_q, size_d;
        entry_t entries_q, entries_d;

        always_comb begin
            mready = 1;
            for (int i = 0; i < DISPATCH_WIDTH; i++) mready &= mdispatch_i[i].ready;
        end

        always_ff @(posedge clk_i) begin
            if (!nrst) begin
                size_q <= '0;
            end
            else begin
                size_q    <= size_d;
                entries_q <= entries_d;
            end
        end

        always_comb begin
            size_d    = size_q;
            entries_d = entries_q;

            sdispatch_o = '0;
            mdispatch_o = '0;

            if (flush_i) begin
                size_d = '0;
            end
            else begin
                sdispatch_o.ready = size_d != DISPATCH_WIDTH;
                if (sdispatch_i.valid && sdispatch_o.ready) begin
                    entries_d[size_q].pc       = sdispatch_i.pc;
                    entries_d[size_q].dec_inst = sdispatch_i.dec_inst;

                    size_d = size_q + 1;
                end

                for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                    mdispatch_o[i].pc       = entries_d[i].pc;
                    mdispatch_o[i].dec_inst = entries_d[i].dec_inst;
                    mdispatch_o[i].valid = size_d == DISPATCH_WIDTH;
                end

                if (size_d == DISPATCH_WIDTH) begin
                    if (mready) begin
                        size_d = '0;
                    end
                end
            end
        end
    end endgenerate

endmodule
