`include "fu/execution_unit.svh"

module execution_unit_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  iq_commit_o_t [IQ_OUT_WIDTH - 1:0] dispatch_i,
    output iq_commit_i_t [IQ_OUT_WIDTH - 1:0] dispatch_o,

    input  commit_o_t [FU_COUNT - 1:0] commit_i,
    output commit_i_t [FU_COUNT - 1:0] commit_o,

    input  lsq_dispatch_o_t lsq_dispatch_i,
    output lsq_dispatch_i_t lsq_dispatch_o
);

    fu_select_t disp_type [IQ_OUT_WIDTH - 1:0];

    generate
        for (genvar i = 0; i < IQ_OUT_WIDTH; i++) begin
            fu_sel_m fu_sel(
                .dec_inst_i(dispatch_i[i].data.dec_inst),
                .select_o(disp_type[i])
            );
        end
    endgenerate

    iq_commit_o_t alu_dispatchi [ALU_COUNT - 1:0];
    iq_commit_i_t alu_dispatcho [ALU_COUNT - 1:0];
    commit_o_t    alu_commiti   [ALU_COUNT - 1:0];
    commit_i_t    alu_commito   [ALU_COUNT - 1:0];

    iq_commit_o_t jmp_dispatchi [JMP_COUNT - 1:0];
    iq_commit_i_t jmp_dispatcho [JMP_COUNT - 1:0];
    commit_o_t    jmp_commiti   [JMP_COUNT - 1:0];
    commit_i_t    jmp_commito   [JMP_COUNT - 1:0];

    iq_commit_o_t lsu_dispatchi;
    iq_commit_i_t lsu_dispatcho;

    generate
        for (genvar i = 0; i < ALU_COUNT; i++) begin
            alu_m alu(
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .dispatch_i(alu_dispatchi[i]),
                .dispatch_o(alu_dispatcho[i]),

                .commit_i(alu_commiti[i]),
                .commit_o(alu_commito[i])
            );
        end

        for (genvar i = 0; i < JMP_COUNT; i++) begin
            jmp_m jmp(
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .dispatch_i(jmp_dispatchi[i]),
                .dispatch_o(jmp_dispatcho[i]),

                .commit_i(jmp_commiti[i]),
                .commit_o(jmp_commito[i])
            );
        end
    endgenerate

    lsu_m lsu(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .dispatch_i(lsu_dispatchi),
        .dispatch_o(lsu_dispatcho),

        .lsq_dispatch_i(lsq_dispatch_i),
        .lsq_dispatch_o(lsq_dispatch_o)
    );

    always_comb begin
        int alu_idx, jmp_idx, lsu_idx;
        alu_idx = 0;
        jmp_idx = 0;
        lsu_idx = 0;

        for (int i = 0; i < ALU_COUNT; i++) alu_dispatchi[i] = '0;
        for (int i = 0; i < JMP_COUNT; i++) jmp_dispatchi[i] = '0;
        lsu_dispatchi = '0;

        for (int i = 0; i < IQ_OUT_WIDTH; i++) begin
            case (disp_type[i])
                FU_ALU: begin
                    if (alu_idx != ALU_COUNT) begin
                        alu_dispatchi[alu_idx] = dispatch_i[i];

                        alu_idx++;
                    end
                end

                FU_JMP: begin
                    if (jmp_idx != JMP_COUNT) begin
                        jmp_dispatchi[jmp_idx] = dispatch_i[i];

                        jmp_idx++;
                    end
                end

                FU_LSU: begin
                    if (lsu_idx != 1) begin
                        lsu_dispatchi = dispatch_i[i];

                        lsu_idx++;
                    end
                end

                default: ;
            endcase
        end
    end

    always_comb begin
        int alu_idx, jmp_idx, lsu_idx;
        alu_idx = 0;
        jmp_idx = 0;
        lsu_idx = 0;

        for (int i = 0; i < IQ_OUT_WIDTH; i++) dispatch_o[i] = '0;

        for (int i = 0; i < IQ_OUT_WIDTH; i++) begin
            case (disp_type[i])
                FU_ALU: begin
                    if (alu_idx != ALU_COUNT) begin
                        dispatch_o[i]          = alu_dispatcho[alu_idx];

                        alu_idx++;
                    end
                end

                FU_JMP: begin
                    if (jmp_idx != JMP_COUNT) begin
                        dispatch_o[i]          = jmp_dispatcho[jmp_idx];

                        jmp_idx++;
                    end
                end

                FU_LSU: begin
                    if (lsu_idx != 1) begin
                        dispatch_o[i] = lsu_dispatcho;

                        lsu_idx++;
                    end
                end

                default: ;
            endcase
        end
    end

    always_comb begin
        int i;
        i = 0;

        for (int j = 0; j < ALU_COUNT; j++) begin
            alu_commiti[j] = commit_i[i];
            commit_o[i]    = alu_commito[j];

            i++;
        end

        for (int j = 0; j < JMP_COUNT; j++) begin
            jmp_commiti[j] = commit_i[i];
            commit_o[i]    = jmp_commito[j];

            i++;
        end
    end

endmodule
