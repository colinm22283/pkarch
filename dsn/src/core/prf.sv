`timescale 1ns/100ps

`include "config.svh"
`include "defs.svh"
`include "core/prf.svh"
`include "test/logger.svh"

module prf_m(
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

    localparam INDEX_WIDTH = $clog2(PRF_SIZE);

    prf_mem_rport_req_i_t [PRF_MEM_RPORTS - 1:0] mem_reqi;
    prf_mem_rport_req_o_t [PRF_MEM_RPORTS - 1:0] mem_reqo;

    logic mem_valid [PRF_SIZE - 1:0];

    prf_mem_m mem(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush_i),

        .prf_wport_i(prf_wport_i),
        
        .prf_rport_req_i(mem_reqi),
        .prf_rport_req_o(mem_reqo),

        .prf_rport_ack_i(prf_rport_ack_i),
        .prf_rport_ack_o(prf_rport_ack_o)
    );

    prf_addr_t rport_addr   [PRF_RPORTS - 1:0];
    logic      rport_valid  [PRF_RPORTS - 1:0];
    logic      rport_port   [PRF_RPORTS - 1:0];
    rob_id_t   rport_rob_id [PRF_RPORTS - 1:0];

    logic rport_accept [PRF_RPORTS - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < PRF_RPORTS; i++) begin
                rport_valid[i] <= 0;
            end

            for (int i = 0; i < PRF_SIZE; i++) begin
                mem_valid[i] <= 0;
            end
        end
        else if (flush_i) begin
            for (int i = 0; i < PRF_RPORTS; i++) begin
                rport_valid[i] <= 0;
            end
        end
        else begin
            for (int i = 0; i < PRF_WPORTS; i++) begin
                if (prf_wport_i[i].we && prf_wport_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Write 0x%h to 0x%h", prf_wport_i[i].data, prf_wport_i[i].addr));

                    mem_valid[INDEX_WIDTH'(prf_wport_i[i].addr)] <= 1;
                end
            end

            for (int i = 0; i < PRF_RELPORTS; i++) begin
                if (prf_rel_i[i].rel && prf_rel_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Release 0x%h", prf_rel_i[i].addr));

                    mem_valid[INDEX_WIDTH'(prf_rel_i[i].addr)] <= 0;
                end
            end

            for (int i = 0; i < PRF_RPORTS; i++) begin
                if (rport_accept[i]) begin
                    rport_valid[i] <= 'b0;
                end
            end
            
            for (int i = 0; i < PRF_RPORTS; i++) begin
                if (prf_rport_req_i[i].req && prf_rport_req_o[i].ready) begin
                    rport_valid[i] <= 'b1;
                    rport_port[i]   <= prf_rport_req_i[i].port;
                    rport_rob_id[i] <= prf_rport_req_i[i].rob_id;
                    rport_addr[i]   <= prf_rport_req_i[i].addr;
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < PRF_RPORTS; i++) begin
            prf_rport_req_o[i].ready = !rport_valid[i] || rport_accept[i];
        end
    end

    always_comb begin
        logic [$clog2(PRF_MEM_RPORTS + 1) - 1:0] current_rport;
        current_rport = '0;

        mem_reqi = '0;

        for (int i = 0; i < PRF_RPORTS; i++) begin
            rport_accept[i] = '0;

            if (current_rport < PRF_MEM_RPORTS) begin
                if (rport_valid[i] && mem_reqo[current_rport].ready) begin
                    if (
                        rport_addr[i] == PRF_ZERO_ADDR ||
                        mem_valid[INDEX_WIDTH'(rport_addr[i])]
                    ) begin
                        rport_accept[i] = 'b1;

                        mem_reqi[current_rport].valid  = 'b1;
                        mem_reqi[current_rport].port   = rport_port[i];
                        mem_reqi[current_rport].rob_id = rport_rob_id[i];
                        mem_reqi[current_rport].addr   = rport_addr[i];

                        current_rport++;
                    end
                end
            end
        end
    end

endmodule

