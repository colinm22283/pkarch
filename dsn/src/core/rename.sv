`include "config.svh"
`include "core/rename.svh"
`include "core/prf.svh"
`include "test/logger.svh"

module rename_m(
    input wire clk_i,
    input wire nrst_i,

    input  wire flush_i,

    input  wire jump_i,
    output logic jump_accept_o,

    input  wire jump_commit_i,

    input  rename_dispatch_i_t [RENAME_WIDTH - 1:0] dispatch_i,
    output rename_dispatch_o_t [RENAME_WIDTH - 1:0] dispatch_o,

    input  rename_commit_i_t [COMMIT_WIDTH - 1:0] commit_i,
    output rename_commit_o_t [COMMIT_WIDTH - 1:0] commit_o,

    output prf_rel_i_t [PRF_RELPORTS - 1:0] prf_rel_o
);

    `DL_DEFINE(log, "rename_m", `DL_CYAN, `DL_ENABLE_RENAME);
    `DL_DEFINE(error, "rename_m ERROR", `DL_RED, 1);

    state_logger_m state_logger(.clk_i(clk_i));

    typedef logic [$clog2(PRF_SIZE) - 1:0] fl_index_t;
    typedef logic [$clog2(PRF_SIZE + 1) - 1:0] fl_size_t;

    rename_rat_t spec_rat_q, spec_rat_d;
    rename_rat_t arch_rat_q, arch_rat_d;

    fl_index_t fl_head_q, fl_head_d;
    fl_index_t fl_tail_q, fl_tail_d;
    fl_size_t  fl_size_q, fl_size_d;
    fl_index_t fl_head_cp_q, fl_head_cp_d;
    rename_freelist_t freelist_q, freelist_d;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < REG_COUNT; i++) begin
                spec_rat_q[i] <= PRF_ZERO_ADDR;
                arch_rat_q[i] <= PRF_ZERO_ADDR;
            end

            fl_head_q    <= '0;
            fl_tail_q    <= '0;
            fl_size_q    <= PRF_SIZE;
            fl_head_cp_q <= '0;
            for (int i = 0; i < PRF_SIZE; i++) begin
                freelist_q[i] <= $bits(prf_addr_t)'(i);
            end
        end
        else begin
            for (int i = 0; i < REG_COUNT; i++) begin
                spec_rat_q[i] <= spec_rat_d[i];
                arch_rat_q[i] <= arch_rat_d[i];
            end

            fl_head_q    <= fl_head_d;
            fl_tail_q    <= fl_tail_d;
            fl_size_q    <= fl_size_d;
            fl_head_cp_q <= fl_head_cp_d;
            for (int i = 0; i < PRF_SIZE; i++) begin
                freelist_q[i] <= freelist_d[i];
            end
        end
    end

    always_comb begin
        logic cont;

        for (int i = 0; i < REG_COUNT; i++) begin
            spec_rat_d[i] = spec_rat_q[i];
            arch_rat_d[i] = arch_rat_q[i];
        end

        fl_head_d    = fl_head_q;
        fl_tail_d    = fl_tail_q;
        fl_size_d    = fl_size_q;
        fl_head_cp_d = fl_head_cp_q;
        for (int i = 0; i < PRF_SIZE; i++) begin
            freelist_d[i] = freelist_q[i];
        end

        jump_accept_o = 'b1;
        // if (jump_i) begin
            // cp_head
        // end

        cont = 'b1;
        for (int i = 0; i < RENAME_WIDTH; i++) begin
            dispatch_o[i].prev_addr = spec_rat_d[dispatch_i[i].isa_addr];

            prf_rel_o[i].rel  = '0;

            if (cont) begin
                if (dispatch_i[i].write) begin
                    dispatch_o[i].ready    = fl_size_d != '0;

                    if (dispatch_i[i].isa_addr == REG_ZERO) dispatch_o[i].prf_addr = PRF_ZERO_ADDR;
                    else begin
                        dispatch_o[i].prf_addr = freelist_q[fl_head_d];

                        if (dispatch_i[i].valid && dispatch_o[i].ready) begin
                            spec_rat_d[dispatch_i[i].isa_addr] = freelist_q[fl_head_d];
                            fl_head_d++;
                            fl_size_d--;

                            prf_rel_o[i].rel = 'b1;
                        end
                    end
                end
                else begin
                    dispatch_o[i].ready    = 'b1;
                    dispatch_o[i].prf_addr = spec_rat_d[dispatch_i[i].isa_addr];
                end

                if (!dispatch_o[i].ready) cont = '0;
            end
            else begin
                dispatch_o[i].ready    = '0;
                dispatch_o[i].prf_addr = '0;
            end

            prf_rel_o[i].addr = dispatch_o[i].prf_addr;
        end

        for (int i = 0; i < COMMIT_WIDTH; i++) begin
            commit_o[i].ready = 'b1;

            if (commit_i[i].valid && commit_i[i].isa_addr != REG_ZERO) begin
                if (commit_i[i].prev_addr != PRF_ZERO_ADDR) begin
                    fl_tail_d++;
                    fl_size_d++;
                    fl_head_cp_d = fl_head_d;

                    freelist_d[fl_tail_d] = commit_i[i].prev_addr;
                end

                arch_rat_d[commit_i[i].isa_addr] = commit_i[i].prf_addr;
            end
        end

        if (flush_i) begin
            spec_rat_d = arch_rat_q;
            fl_head_d = fl_head_cp_q;
        end
    end

endmodule

