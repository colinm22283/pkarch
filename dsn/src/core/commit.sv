`timescale 1ns/100ps

`include "config.svh"
`include "core/commit.svh"

module commit_m(
    input wire clk_i,
    input wire nrst_i,

    input  commit_i_t [COMMIT_COUNT - 1:0] commit_i,
    output commit_o_t [COMMIT_COUNT - 1:0] commit_o,

    input  rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] rob_commit_i,
    output rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] rob_commit_o,

    output prf_wport_i_t [ROB_COMMIT_WIDTH - 1:0] prf_wport_o
);

    generate if (COMMIT_DEBUG_REGFILE) begin
        word_t regfile [31:0];

        wire word_t dbg_zero = regfile[REG_ZERO];
        wire word_t dbg_ra   = regfile[REG_RA];
        wire word_t dbg_sp   = regfile[REG_SP];
        wire word_t dbg_gp   = regfile[REG_GP];
        wire word_t dbg_tp   = regfile[REG_TP];
        wire word_t dbg_t0   = regfile[REG_T0];
        wire word_t dbg_t1   = regfile[REG_T1];
        wire word_t dbg_t2   = regfile[REG_T2];
        wire word_t dbg_s0   = regfile[REG_S0];
        wire word_t dbg_s1   = regfile[REG_S1];
        wire word_t dbg_a0   = regfile[REG_A0];
        wire word_t dbg_a1   = regfile[REG_A1];
        wire word_t dbg_a2   = regfile[REG_A2];
        wire word_t dbg_a3   = regfile[REG_A3];
        wire word_t dbg_a4   = regfile[REG_A4];
        wire word_t dbg_a5   = regfile[REG_A5];
        wire word_t dbg_a6   = regfile[REG_A6];
        wire word_t dbg_a7   = regfile[REG_A7];
        wire word_t dbg_s2   = regfile[REG_S2];
        wire word_t dbg_s3   = regfile[REG_S3];
        wire word_t dbg_s4   = regfile[REG_S4];
        wire word_t dbg_s5   = regfile[REG_S5];
        wire word_t dbg_s6   = regfile[REG_S6];
        wire word_t dbg_s7   = regfile[REG_S7];
        wire word_t dbg_s8   = regfile[REG_S8];
        wire word_t dbg_s9   = regfile[REG_S9];
        wire word_t dbg_s10  = regfile[REG_S10];
        wire word_t dbg_s11  = regfile[REG_S11];
        wire word_t dbg_t3   = regfile[REG_T3];
        wire word_t dbg_t4   = regfile[REG_T4];
        wire word_t dbg_t5   = regfile[REG_T5];
        wire word_t dbg_t6   = regfile[REG_T6];

        always_ff @(posedge clk_i) begin
            if (!nrst_i) begin
                for (int i = 0; i < 32; i++) regfile[i] = '0;
            end
            else begin
                for (int i = 0; i < COMMIT_COUNT; i++) begin
                    if (commit_i[i].valid && commit_o[i].ready) begin
                        regfile[commit_i[i].isa_addr] = commit_i[i].value;
                    end
                end
            end
        end
    end endgenerate

    always_comb begin
        logic [$clog2(ROB_COMMIT_WIDTH + 1) - 1:0] commit_num;

        commit_num = 0;

        rob_commit_o = 0;
        prf_wport_o  = 0;
        commit_o     = 0;

        for (int i = 0; i < COMMIT_COUNT; i++) begin
            if (commit_i[i].valid && commit_num < ROB_COMMIT_WIDTH) begin
                commit_o[i].ready = rob_commit_i[commit_num].ready;

                rob_commit_o[commit_num].valid      = 1;
                rob_commit_o[commit_num].rob_id     = commit_i[i].rob_id;
                rob_commit_o[commit_num].jmp        = commit_i[i].jmp;
                rob_commit_o[commit_num].mispred    = commit_i[i].mispred;
                rob_commit_o[commit_num].jmp_target = commit_i[i].jmp_target;
                rob_commit_o[commit_num].mem        = commit_i[i].mem;
                rob_commit_o[commit_num].rd_a       = commit_i[i].rd_a;
                rob_commit_o[commit_num].isa_addr   = commit_i[i].isa_addr;
                rob_commit_o[commit_num].prev_addr  = commit_i[i].prev_rd;
                rob_commit_o[commit_num].prf_addr   = commit_i[i].rd;

                prf_wport_o[commit_num].we = commit_i[i].rd_a;
                prf_wport_o[commit_num].addr = commit_i[i].rd;
                prf_wport_o[commit_num].data = commit_i[i].value;

                commit_num = commit_num + 1;
            end
        end
    end

endmodule
