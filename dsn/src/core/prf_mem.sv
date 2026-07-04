`timescale 1ns/100ps

`include "config.svh"
`include "core/prf.svh"
`include "test/logger.svh"

module prf_mem_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  prf_mem_wport_i_t [PRF_WPORTS - 1:0]     prf_wport_i,

    input  prf_mem_rport_i_t [PRF_MEM_RPORTS - 1:0] prf_rport_i,
    output prf_mem_rport_o_t [PRF_MEM_RPORTS - 1:0] prf_rport_o,

    input  prf_mem_rel_i_t   [COMMIT_WIDTH - 1:0]   prf_rel_i
);

    `DL_DEFINE(log, "prf_mem_m", `DL_MAGENTA, `DL_ENABLE_PRF);

    localparam INDEX_WIDTH = $clog2(PRF_SIZE);

    prf_entry_t mem [PRF_SIZE - 1:0];

    logic [PRF_SIZE - 1:0] valids;
    always_comb begin
        for (int i = 0; i < PRF_SIZE; i++) begin
            valids[i] = mem[i].valid;
        end
    end

    prf_addr_t          read_addr  [PRF_MEM_RPORTS - 1:0];
    prf_mem_rport_tag_t addr_tag   [PRF_MEM_RPORTS - 1:0];
    logic               addr_valid [PRF_MEM_RPORTS - 1:0];

    word_t              read_data  [PRF_MEM_RPORTS - 1:0];
    prf_mem_rport_tag_t data_tag   [PRF_MEM_RPORTS - 1:0];
    logic               data_valid [PRF_MEM_RPORTS - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < PRF_SIZE; i++) begin
                mem[i].valid <= 0;
            end
        end
        else begin
            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                if (prf_rel_i[i].rel && prf_rel_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Release 0x%h", prf_rel_i[i].addr));

                    mem[INDEX_WIDTH'(prf_rel_i[i].addr)].valid <= 0;
                end
            end

            for (int i = 0; i < PRF_WPORTS; i++) begin
                if (prf_wport_i[i].we && prf_wport_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Write 0x%h to 0x%h", prf_wport_i[i].data, prf_wport_i[i].addr));

                    mem[INDEX_WIDTH'(prf_wport_i[i].addr)].valid <= 1;
                    mem[INDEX_WIDTH'(prf_wport_i[i].addr)].data <= prf_wport_i[i].data;
                end
            end

            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                read_addr[i]  <= prf_rport_i[i].addr;
                addr_tag[i]   <= prf_rport_i[i].tag;
                addr_valid[i] <= prf_rport_i[i].req;
            end

            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                if (read_addr[i] != PRF_ZERO_ADDR) begin
                    read_data  <= mem[INDEX_WIDTH'(read_addr[i])].data;
                    data_valid <= mem[INDEX_WIDTH'(read_addr[i])].valid && addr_valid[i];
                end
                else begin
                    read_data[i]  <= 0;
                    data_valid[i] <= addr_valid[i];
                end

                data_tag[i] <= addr_tag[i];
            end
        end
    end

    always_comb begin
        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            prf_rport_o[i].data = read_data[i];
            prf_rport_o[i].tag  = data_tag[i];
            prf_rport_o[i].ack  = data_valid[i];
        end
    end

endmodule

