`timescale 1ns/100ps

`include "config.svh"
`include "rob.svh"

module rob_m(
    input wire clk_i,
    input wire nrst_i,

    input  rob_dispatch_i_t [ROB_WIDTH - 1:0] dispatch_i,
    output rob_dispatch_o_t [ROB_WIDTH - 1:0] dispatch_o
);

    rob_id_t head, tail;
    logic [$clog2(ROB_SIZE + 1) - 1:0] size;

    rob_entry_t [ROB_SIZE - 1:0] entries;

    logic dispatch_any_ready;
    always_comb begin
        dispatch_any_ready = 1;
        for (int i = 0; i < ROB_WIDTH; i++) dispatch_any_ready |= dispatch_i[i].valid;
    end

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head <= 0;
            tail <= 0;
            size <= 0;
        end
        else begin
            if (dispatch_any_ready) begin
                for (int i = 0; i < ROB_WIDTH; i++) begin
                    if (dispatch_i[i].valid) begin
                        
                    end
                end
            end
        end
    end

endmodule
