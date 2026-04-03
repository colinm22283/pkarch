`timescale 1ns/100ps

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

    output prf_wport_i_t [ROB_COMMIT_WIDTH - 1:0] prf_wport_o
);

    logic [FU_COUNT - 1:0] commit_ready;
    logic [FU_COUNT - 1:0] commit_valid;

    always_comb begin
        logic [$clog2(ROB_COMMIT_WIDTH + 1) - 1:0] commit_num;

        commit_num = 0;

        rob_commit_o = 0;
        prf_wport_o  = 0;
        commit_o     = 0;

        for (int i = 0; i < FU_COUNT; i++) begin
            if (commit_i[i].valid && commit_num < ROB_COMMIT_WIDTH) begin
                commit_o[i].ready = rob_commit_i[commit_num].ready;

                rob_commit_o[commit_num].valid  = 1;
                rob_commit_o[commit_num].rob_id = commit_i[i].rob_id;
                rob_commit_o[commit_num].rd_a   = commit_i[i].rd_a;
                rob_commit_o[commit_num].isa_addr = commit_i[i].isa_addr;
                rob_commit_o[commit_num].prf_addr = commit_i[i].rd;

                prf_wport_o[commit_num].we = commit_i[i].rd_a;
                prf_wport_o[commit_num].addr = commit_i[i].rd;
                prf_wport_o[commit_num].data = commit_i[i].value;

                commit_num = commit_num + 1;
            end
        end
    end

endmodule
