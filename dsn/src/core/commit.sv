`include "fu.svh"
`include "commit.svh"
`include "config.svh"

module commit_m(
    input wire clk_i,
    input wire nrst_i,

    input  commit_i_t [FU_COUNT - 1:0] commit_i,
    output commit_o_t [FU_COUNT - 1:0] commit_o,

    input  rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] rob_commit_i,
    output rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] rob_commit_o,

    output prf_wport_i_t [PRF_WPORTS - 1:0] prf_wport_o
);

    logic [FU_COUNT - 1:0] commit_ready;
    logic [FU_COUNT - 1:0] commit_valid;

    always_comb begin
        logic [$clog2(COMMIT_WIDTH + 1) - 1:0] commit_num;

        commit_num = 0;

        for (int i = 0; i < FU_COUNT; i++) begin
            if (commit_i[i].valid) begin
            end
        end
    end

endmodule
