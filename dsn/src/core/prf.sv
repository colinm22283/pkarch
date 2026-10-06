`timescale 1ns/100ps

`include "config.svh"
`include "defs.svh"
`include "core/prf.svh"
`include "test/logger.svh"

module prf_m(
`ifdef USE_POWER_PINS
    inout wire vccd1,
    inout wire vssd1,
`endif

    input wire clk_i,
    input wire nrst_i,

    input logic flush_i,
    input  wire jump_i,
    input  wire jump_commit_i,

    input  prf_wport_i_t [PRF_WPORTS - 1:0] prf_wport_i,

    input  prf_rport_req_i_t [PRF_RPORTS - 1:0] prf_rport_req_i,
    output prf_rport_req_o_t [PRF_RPORTS - 1:0] prf_rport_req_o,

    input  prf_rport_ack_i_t [PRF_MEM_RPORTS - 1:0] prf_rport_ack_i,
    output prf_rport_ack_o_t [PRF_MEM_RPORTS - 1:0] prf_rport_ack_o,

    input  prf_rel_i_t [PRF_RELPORTS - 1:0] prf_rel_i
);

    `DL_DEFINE(log, "prf_m", `DL_MAGENTA, `DL_ENABLE_PRF);

    logic nrst;
    reset_buf_m reset_buf(
        .clk_i(clk_i),
        .nrst_i(nrst_i),
        .nrst_o(nrst)
    );

    localparam INDEX_WIDTH = $clog2(PRF_SIZE);

    prf_mem_rport_req_i_t [PRF_MEM_RPORTS - 1:0] mem_reqi;
    prf_mem_rport_req_o_t [PRF_MEM_RPORTS - 1:0] mem_reqo;

    logic mem_valid_q [PRF_SIZE - 1:0];
    logic mem_valid_d [PRF_SIZE - 1:0];

    prf_mem_m mem(
        .clk_i(clk_i),
        .nrst_i(nrst),

        .flush_i(flush_i),

        .prf_wport_i(prf_wport_i),
        
        .prf_rport_req_i(mem_reqi),
        .prf_rport_req_o(mem_reqo),

        .prf_rport_ack_i(prf_rport_ack_i),
        .prf_rport_ack_o(prf_rport_ack_o)
    );

    always_ff @(posedge clk_i) begin
        if (!nrst) begin
            for (int i = 0; i < PRF_SIZE; i++) mem_valid_q[i] <= '0;
        end
        else begin
            mem_valid_q <= mem_valid_d;
        end
    end

    always_comb begin
        logic [$clog2(PRF_MEM_RPORTS + 1) - 1:0] mem_rport_index;
        mem_rport_index = '0;

        mem_valid_d = mem_valid_q;

        mem_reqi = '0;

        if (!flush_i) begin
            for (int i = 0; i < PRF_WPORTS; i++) begin
                if (prf_wport_i[i].we && prf_wport_i[i].addr != PRF_ZERO_ADDR) begin
                    mem_valid_d[INDEX_WIDTH'(prf_wport_i[i].addr)] = 1'b1;
                end
            end

            for (int i = 0; i < PRF_RELPORTS; i++) begin
                if (prf_rel_i[i].rel && prf_rel_i[i].addr != PRF_ZERO_ADDR) begin
                    mem_valid_d[INDEX_WIDTH'(prf_rel_i[i].addr)] = 1'b0;
                end
            end

            for (int i = 0; i < PRF_RPORTS; i++) begin
                prf_rport_req_o[i].ready = mem_valid_q[INDEX_WIDTH'(prf_rport_req_i[i].addr)];

                if (
                    prf_rport_req_i[i].req &&
                    (
                        mem_valid_q[INDEX_WIDTH'(prf_rport_req_i[i].addr)] ||
                        prf_rport_req_i[i].addr == PRF_ZERO_ADDR
                    ) &&
                    mem_rport_index != PRF_MEM_RPORTS &&
                    mem_reqo[mem_rport_index].ready
                ) begin
                    mem_reqi[mem_rport_index].valid  = 1'b1;
                    mem_reqi[mem_rport_index].port   = prf_rport_req_i[i].port;
                    mem_reqi[mem_rport_index].rob_id = prf_rport_req_i[i].rob_id;
                    mem_reqi[mem_rport_index].addr   = prf_rport_req_i[i].addr;

                    mem_rport_index++;
                end
            end
        end
    end

endmodule

