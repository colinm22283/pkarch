`timescale 1ns/100ps

module fetch_expander_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  dispatch_i_t sdispatch_i,
    output dispatch_o_t sdispatch_o,

    input  dispatch_o_t [DISPATCH_WIDTH - 1:0] mdispatch_i,
    output dispatch_i_t [DISPATCH_WIDTH - 1:0] mdispatch_o
);

    typedef struct packed {
        pc_t pc;
        dec_inst_t dec_inst;
    } [DISPATCH_WIDTH - 1:0] entry_t;
    
    logic mready;

    logic [$clog2(DISPATCH_WIDTH + 1) - 1:0] size;
    entry_t entries;

    always_comb begin
        mready = 1;
        for (int i = 0; i < DISPATCH_WIDTH; i++) mready &= mdispatch_i[i].ready;
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
                if (size == DISPATCH_WIDTH) begin
                    if (mready) size <= 0;
                end
                else begin
                    if (sdispatch_i.valid) begin
                        entries[size].pc       <= sdispatch_i.pc;
                        entries[size].dec_inst <= sdispatch_i.dec_inst;

                        $display("PC: %h", sdispatch_i.pc);

                        size <= size + 1;
                    end
                end
            end
        end
    end
    
    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            mdispatch_o[i].valid    = size == DISPATCH_WIDTH;
            mdispatch_o[i].pc       = entries[i].pc;
            mdispatch_o[i].dec_inst = entries[i].dec_inst;
        end

        sdispatch_o.ready = size != DISPATCH_WIDTH;
    end

endmodule
