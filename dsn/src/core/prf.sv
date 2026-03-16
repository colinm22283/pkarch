`include "config.svh"
`include "prf.svh"
`include "defs.svh"

module prf_m(
    input wire clk_i,
    input wire nrst_i,

    input  prf_wport_i_t [COMMIT_WIDTH - 1:0] prf_wport_i
);

    word_t [PRF_SIZE - 1:0] mem;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
        end
        else begin
            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                if (prf_wport_i[i].we) begin
                    $display("Write 0x%h to 0x%h", prf_wport_i[i].data, prf_wport_i[i].addr);

                    mem[prf_wport_i[i].addr] <= prf_wport_i[i].data;
                end
            end
        end
    end

    // always_comb begin
        // for (int i = 0; i < PRF_PORTS; i++) begin
            // prf_port_o[i].data = mem[prf_port_i[i].addr];
        // end
    // end

endmodule
