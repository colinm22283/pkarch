`timescale 1ns/100ps

`include "isa.svh"
`include "core/fetch.svh"
`include "core/dispatch.svh"
`include "test/logger.svh"
`include "bus/icache.svh"

module fetch_m(
    input wire clk_i,
    input wire nrst_i,

    input  icache_o_t icache_i,
    output icache_i_t icache_o,

    input  fetch_jump_i_t jump_i,
    output fetch_jump_o_t jump_o,

    input  wire flush_complete_i,
    output wire flush_o,

    input  dispatch_o_t dispatch_i,
    output dispatch_i_t dispatch_o
);

    `DL_DEFINE(log, "fetch_m", `DL_CYAN, `DL_ENABLE_FETCH);

    pc_t pc;

    inst_t     inst;
    dec_inst_t dec_inst;

    enum logic [1:0] {
        STATE_RUN,
        STATE_FLUSH
    } state;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state <= STATE_RUN;

            pc <= 0;
        end
        else begin
            case (state)
                STATE_RUN: begin
                    if (jump_i.valid) begin
                        state <= STATE_FLUSH;

                        pc <= jump_i.target;
                    end
                    else begin
                        if (dispatch_i.ready && icache_i.ack) begin
                            `DL(log, ("Instruction dispatch from %h, inst = %h", pc, inst));
                            pc <= pc + 4;
                        end
                    end
                end

                STATE_FLUSH: begin
                    if (flush_complete_i) state <= STATE_RUN;
                end

                default: ;
            endcase
        end
    end

    always_comb begin
        icache_o.addr = pc;
        icache_o.req  = state == STATE_RUN;
        inst          = icache_i.data;

        dispatch_o.pc = pc;
        dispatch_o.dec_inst = dec_inst;
        dispatch_o.valid = icache_i.ack && state == STATE_RUN && !jump_i.valid;

        jump_o.ready = state == STATE_RUN;
        flush_o      = state == STATE_FLUSH;
    end

    decoder_m decoder(
        .inst_i(inst),
        .decoded_o(dec_inst)
    );

endmodule

