`timescale 1ns/100ps

`include "fu.svh"

module res_station_m #(
    parameter SIZE = 3,
    parameter FU_WIDTH = 1
) (
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  res_dispatch_i_t res_dispatch_i,
    output res_dispatch_o_t res_dispatch_o,

    input  fu_test_o_t fu_test_i,
    output fu_test_i_t fu_test_o,

    input  fu_dispatch_o_t [FU_WIDTH - 1:0] fu_dispatch_i,
    output fu_dispatch_i_t [FU_WIDTH - 1:0] fu_dispatch_o
);

    localparam INDEX_WIDTH = $clog2(SIZE);
    localparam SIZE_WIDTH = $clog2(SIZE + 1);

    logic [FU_WIDTH - 1:0] fu_ready;

    res_station_entry_t [SIZE - 1:0] entries;
    logic [SIZE_WIDTH - 1:0] size;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
        end
        else begin
            for (int i = 0; i < FU_WIDTH; i++) begin
                if (fu_ready[i]) begin
                    for (int j = 0; j < SIZE - 1; j++) begin
                        entries[j] = entries[j + 1];
                    end

                    size = size - 1;
                end
            end

            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                if (res_dispatch_o[i].ready) begin
                    entries[size].pc = res_dispatch_i[i].pc;
                    
                    entries[size].dec_inst = res_dispatch_i[i].dec_inst;

                    entries[size].rob_id = res_dispatch_i[i].rob_id;

                    entries[size].rs1 = res_dispatch_i[i].rs1;
                    entries[size].rs2 = res_dispatch_i[i].rs2;
                    entries[size].rd = res_dispatch_i[i].rd;

                    entries[size].isa_addr = res_dispatch_i[i].isa_addr;

                    size = size + 1;
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            fu_test_o[i].dec_inst = res_dispatch_i[i].dec_inst;
        end

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            if (res_dispatch_i[i].valid && fu_test_i[i].accept && SIZE_WIDTH'(size + i) < SIZE) begin
                res_dispatch_o[i].ready = 1'b1;
            end
            else begin
                res_dispatch_o[i].ready = 1'b0;
            end
        end

        begin
            logic [SIZE_WIDTH - 1:0] dispatch_count;

            dispatch_count = 0;

            fu_dispatch_o = 0;
            fu_ready = 0;

            for (int i = 0; i < FU_WIDTH; i++) begin
                if (dispatch_count != size) begin
                    if (fu_dispatch_i[i].ready) begin
                        fu_ready[i] = 1;
                    end

                    fu_dispatch_o[i].valid = 1;

                    fu_dispatch_o[i].pc = entries[dispatch_count].pc;

                    fu_dispatch_o[i].dec_inst = entries[dispatch_count].dec_inst;

                    fu_dispatch_o[i].rob_id = entries[dispatch_count].rob_id;

                    fu_dispatch_o[i].rs1 = entries[dispatch_count].rs1;
                    fu_dispatch_o[i].rs2 = entries[dispatch_count].rs2;
                    fu_dispatch_o[i].rd = entries[dispatch_count].rd;

                    fu_dispatch_o[i].isa_addr = entries[dispatch_count].isa_addr;

                    dispatch_count = dispatch_count + 1;
                end
            end
        end
    end

endmodule

