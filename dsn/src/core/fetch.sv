`timescale 1ns/100ps

`include "isa.svh"
`include "dispatch.svh"
`include "fetch.svh"
`include "logger.svh"
`include "icache.svh"

module fetch_m(
    input wire clk_i,
    input wire nrst_i,

    input  icache_o_t icache_i,
    output icache_i_t icache_o,

    input  fetch_jump_i_t jump_i,
    output fetch_jump_o_t jump_o,

    output wire flush_o,

    input  dispatch_o_t dispatch_i,
    output dispatch_i_t dispatch_o
);

    `DL_DEFINE(log, "fetch_m", `DL_CYAN, `DL_ENABLE_FETCH);

    logic [2:0] state;

    bus_addr_t pc;
    
    logic inst_ready;
    inst_t inst;
    pc_t inst_pc;
    dec_inst_t dec_inst;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state <= 0;

            pc <= 0;

            inst_ready <= 0;
        end
        else begin
            flush_o <= 0;

            case (state)
                0: begin
                    if (jump_i.valid) begin
                        `DL(log, ("Jump requested to 0x%x", jump_i.target));

                        pc <= jump_i.target;
                        flush_o <= 1;
                    end
                    else if (!inst_ready) begin
                        state <= 1;

                        icache_o.req  <= 1;
                        icache_o.addr <= pc;
                    end
                end

                1: begin
                    if (icache_i.ack) begin
                        state <= 0;

                        icache_o.req <= 0;

                        inst_ready <= 1;
                        inst       <= icache_i.data;
                        inst_pc    <= pc;

                        pc <= pc + 4;

                        `DL(log, ("Loaded instruction from 0x%x", pc));
                    end
                end
            endcase

            if (inst_ready && dispatch_i.ready) begin
                inst_ready <= 0;
            end
        end
    end

    always_comb begin
        jump_o.ready = state == 0;

        dispatch_o.valid    = inst_ready;
        dispatch_o.pc       = inst_pc;
        dispatch_o.dec_inst = dec_inst;
    end

    decoder_m decoder(
        .inst_i(inst),
        .decoded_o(dec_inst)
    );

endmodule
    
