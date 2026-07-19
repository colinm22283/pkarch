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

    input  prf_rport_i_t [PRF_RPORTS - 1:0] prf_rport_i,
    output prf_rport_o_t [PRF_RPORTS - 1:0] prf_rport_o,

    input  prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_rel_i
);

    `DL_DEFINE(log, "prf_m", `DL_MAGENTA, `DL_ENABLE_PRF);

    localparam INDEX_WIDTH = $clog2(PRF_SIZE);
    localparam CP_INDEX_WIDTH = $clog2(CHECKPOINT_COUNT);
    localparam CP_SIZE_WIDTH = $clog2(CHECKPOINT_COUNT + 1);

    prf_mem_rport_req_i_t [PRF_MEM_RPORTS - 1:0] mem_reqi;

    prf_mem_rport_ack_o_t [PRF_MEM_RPORTS - 1:0] mem_acko;

    logic [PRF_SIZE - 1:0] mem_valid;

    prf_mem_m mem(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush_i),

        .prf_wport_i(prf_wport_i),
        
        .prf_rport_req_i(mem_reqi),

        .prf_rport_ack_o(mem_acko)
    );

    logic [PRF_RPORTS - 1:0] rport_avail;
    logic [PRF_RPORTS - 1:0] rport_valid;
    logic [PRF_RPORTS - 1:0] rport_accept;

    prf_addr_t [PRF_RPORTS - 1:0] rport_addr;
    prf_addr_t [PRF_RPORTS - 1:0] rport_accept_addr;

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
            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                if (prf_rel_i[i].rel && prf_rel_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Release 0x%h", prf_rel_i[i].addr));

                    mem_valid[INDEX_WIDTH'(prf_rel_i[i].addr)] <= 0;
                end
            end

            for (int i = 0; i < PRF_WPORTS; i++) begin
                if (prf_wport_i[i].we && prf_wport_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Write 0x%h to 0x%h", prf_wport_i[i].data, prf_wport_i[i].addr));

                    mem_valid[INDEX_WIDTH'(prf_wport_i[i].addr)] <= 1;
                end
            end

            for (int i = 0; i < PRF_RPORTS; i++) begin
                if (rport_avail[i] && !rport_accept[i]) begin
                    rport_valid[i] <= 1;
                    rport_addr[i] <= prf_rport_i[i].addr;
                end

                if (!rport_avail[i] && rport_accept[i]) rport_valid[i] <= 0;
            end
        end
    end

    always_comb begin
        for (int i = 0; i < PRF_RPORTS; i++) begin
            rport_avail[i] = prf_rport_i[i].req;

            if (rport_valid[i]) rport_accept_addr[i] = rport_addr[i];
            else rport_accept_addr[i]                = prf_rport_i[i].addr;
        end
    end

    always_comb begin
        integer current_rport;

        current_rport = 0;

        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            mem_reqi[i] = 0;
        end

        for (int i = 0; i < PRF_RPORTS; i++) begin
            rport_accept[i] = 0;

            if (current_rport < PRF_MEM_RPORTS) begin
                if (
                    rport_accept_addr[i] == PRF_ZERO_ADDR ||
                    mem_valid[INDEX_WIDTH'(rport_accept_addr[i])]
                ) begin
                    if (
                        rport_valid[i] ||
                        rport_avail[i]
                    ) begin
                        rport_accept[i] = 1;

                        mem_reqi[current_rport].valid = 1;
                        mem_reqi[current_rport].tag   = $bits(prf_rport_tag_t)'(i);
                        mem_reqi[current_rport].addr  = rport_accept_addr[i];

                        current_rport++;
                    end
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < PRF_RPORTS; i++) begin
            prf_rport_o[i] = 0;
        end

        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            if (mem_acko[i].valid) begin
                prf_rport_o[mem_acko[i].tag].ack  = 1;
                prf_rport_o[mem_acko[i].tag].data = mem_acko[i].data;
            end
        end
    end

endmodule
