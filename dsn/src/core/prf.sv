`include "config.svh"
`include "prf.svh"
`include "defs.svh"

module prf_m(
    input wire clk_i,
    input wire nrst_i,

    input  prf_wport_i_t [PRF_WPORTS - 1:0] prf_wport_i,

    input  prf_rport_i_t [PRF_RPORTS - 1:0] prf_rport_i,
    output prf_rport_o_t [PRF_RPORTS - 1:0] prf_rport_o,

    input  prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_rel_i
);

    prf_entry_t [PRF_SIZE - 1:0] mem;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < PRF_SIZE; i++) begin
                mem[i].valid = 0;
            end
        end
        else begin
            for (int i = 0; i < PRF_RPORTS; i++) begin
                prf_rport_o[i].valid = mem[prf_rport_i[i].addr].valid;
                prf_rport_o[i].data = mem[prf_rport_i[i].addr].data;
            end

            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                if (prf_rel_i[i].rel) begin
                    mem[prf_rel_i[i].addr].valid = 0;
                end
            end

            for (int i = 0; i < PRF_WPORTS; i++) begin
                if (prf_wport_i[i].we) begin
                    $display("Write 0x%h to 0x%h", prf_wport_i[i].data, prf_wport_i[i].addr);

                    mem[prf_wport_i[i].addr].valid = 1;
                    mem[prf_wport_i[i].addr].data = prf_wport_i[i].data;
                end
            end
        end
    end

endmodule
