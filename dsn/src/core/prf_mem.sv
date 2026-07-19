`timescale 1ns/100ps

`include "config.svh"
`include "core/prf.svh"
`include "test/logger.svh"

module prf_mem_m(
    input  logic clk_i,
    input  logic nrst_i,
    
    input  logic flush_i,

    input  prf_mem_wport_i_t [PRF_WPORTS - 1:0] prf_wport_i,

    input  prf_mem_rport_req_i_t [PRF_MEM_RPORTS - 1:0] prf_rport_req_i,

    output prf_mem_rport_ack_o_t [PRF_MEM_RPORTS - 1:0] prf_rport_ack_o
);

    `DL_DEFINE(log, "prf_mem_m", `DL_MAGENTA, `DL_ENABLE_PRF);

    localparam INDEX_WIDTH = $clog2(PRF_SIZE);

    prf_entry_t [PRF_SIZE - 1:0] mem;

    prf_addr_t      read_addr  [PRF_MEM_RPORTS - 1:0];
    prf_rport_tag_t addr_tag   [PRF_MEM_RPORTS - 1:0];
    logic           addr_valid [PRF_MEM_RPORTS - 1:0];

    word_t          read_data  [PRF_MEM_RPORTS - 1:0];
    prf_rport_tag_t data_tag   [PRF_MEM_RPORTS - 1:0];
    logic           data_valid [PRF_MEM_RPORTS - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                addr_valid[i] <= 0;
                data_valid[i] <= 0;
            end
        end
        else if (flush_i) begin
            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                addr_valid[i] <= 0;
                data_valid[i] <= 0;
            end
        end
        else begin
            for (int i = 0; i < PRF_WPORTS; i++) begin
                if (prf_wport_i[i].we && prf_wport_i[i].addr != PRF_ZERO_ADDR) begin
                    `DL(log, ("Write 0x%h to 0x%h", prf_wport_i[i].data, prf_wport_i[i].addr));

                    mem[INDEX_WIDTH'(prf_wport_i[i].addr)].data <= prf_wport_i[i].data;
                end
            end

            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                read_addr[i]  <= prf_rport_req_i[i].addr;
                addr_tag[i]   <= prf_rport_req_i[i].tag;
                addr_valid[i] <= prf_rport_req_i[i].valid;
            end

            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                if (read_addr[i] != PRF_ZERO_ADDR) begin
                    read_data[i]  <= mem[INDEX_WIDTH'(read_addr[i])].data;
                    data_valid[i] <= addr_valid[i];
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
            prf_rport_ack_o[i].data  = read_data[i];
            prf_rport_ack_o[i].tag   = data_tag[i];
            prf_rport_ack_o[i].valid = data_valid[i];
        end
    end

endmodule

