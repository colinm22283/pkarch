`include "config.svh"
`include "prf.svh"
`include "defs.svh"

module prf_m(
    input wire clk_i,
    input wire nrst_i,

    input  prf_port_i_t [PRF_PORTS - 1:0] prf_port_i,
    output prf_port_o_t [PRF_PORTS - 1:0] prf_port_o
);

    word_t [PRF_SIZE - 1:0] mem;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
        end
        else begin
            for (int i = 0; i < PRF_PORTS; i++) begin
                if (prf_port_i[i].we) begin
                    $display("Write 0x%h to 0x%h", prf_port_i[i].data, prf_port_i[i].addr);

                    mem[prf_port_i[i].addr] <= prf_port_i[i].data;
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < PRF_PORTS; i++) begin
            prf_port_o[i].data = mem[prf_port_i[i].addr];
        end
    end

endmodule
