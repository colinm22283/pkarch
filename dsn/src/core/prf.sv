`timescale 1ns/100ps

`include "config.svh"
`include "defs.svh"
`include "core/prf.svh"
`include "test/logger.svh"

module prf_m(
    input wire clk_i,
    input wire nrst_i,

    input  prf_wport_i_t [PRF_WPORTS - 1:0] prf_wport_i,

    input  prf_rport_i_t [PRF_RPORTS - 1:0] prf_rport_i,
    output prf_rport_o_t [PRF_RPORTS - 1:0] prf_rport_o,

    input  prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_rel_i
);

    `DL_DEFINE(log, "prf_m", `DL_MAGENTA, `DL_ENABLE_PRF);

    prf_mem_rport_i_t [PRF_MEM_RPORTS - 1:0] mem_rporti;
    prf_mem_rport_o_t [PRF_MEM_RPORTS - 1:0] mem_rporto;

    prf_mem_m mem(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .prf_wport_i(prf_wport_i),
        
        .prf_rport_i(mem_rporti),
        .prf_rport_o(mem_rporto),

        .prf_rel_i(prf_rel_i)
    );

    always_comb begin
        logic [$clog2(PRF_MEM_RPORTS + 1) - 1:0] mem_port;

        mem_port = 0;

        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            mem_rporti[i].req  = 0;
            mem_rporti[i].tag  = 0;
            mem_rporti[i].addr = 0;
        end

        for (int i = 0; i < PRF_RPORTS; i++) begin
            if (mem_port < PRF_MEM_RPORTS && prf_rport_i[i].req) begin
                mem_rporti[mem_port].req  = 1;
                mem_rporti[mem_port].tag  = i;
                mem_rporti[mem_port].addr = prf_rport_i[i].addr;

                mem_port++;
            end
        end
    end

    always_comb begin
        for (int i = 0; i < PRF_RPORTS; i++) begin
            prf_rport_o[i].ack  = 0;
            prf_rport_o[i].data = 0;
        end

        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            if (mem_rporto[i].ack) begin
                prf_rport_o[mem_rporto[i].tag].ack  = 1;
                prf_rport_o[mem_rporto[i].tag].data = mem_rporto[i].data;
            end
        end
    end

endmodule
