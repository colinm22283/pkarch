`timescale 1ns/100ps

`include "config.svh"
`include "core/rob.svh"
`include "core/rename.svh"
`include "core/fetch.svh"
`include "test/logger.svh"

module rob_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,
    
    output logic rename_jump_commit_o,

    input  rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_i,
    output rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_o,

    input  rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] commit_i,
    output rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] commit_o,

    input  rename_commit_o_t [COMMIT_WIDTH - 1:0] rename_commit_i,
    output rename_commit_i_t [COMMIT_WIDTH - 1:0] rename_commit_o,

    input  fetch_jump_o_t jump_i,
    output fetch_jump_i_t jump_o,

    input  wire rob_write_ready_i,
    output logic rob_write_valid_o
);

`ifdef ROB_COMMIT_COUNTER
    integer commit_count_q, commit_count_d;
`endif

    `DL_DEFINE(log, "rob_m", `DL_YELLOW, `DL_ENABLE_ROB);

    localparam INDEX_WIDTH = $clog2(ROB_SIZE);
    localparam SIZE_WIDTH = $clog2(ROB_SIZE + 1);

    rob_entry_t entries_q [ROB_SIZE - 1:0] [ROB_DISPATCH_WIDTH - 1:0];
    rob_entry_t entries_d [ROB_SIZE - 1:0] [ROB_DISPATCH_WIDTH - 1:0];

    logic [INDEX_WIDTH - 1:0] head_q, head_d;
    logic                     head_wrap_q, head_wrap_d;
    logic [INDEX_WIDTH - 1:0] tail_q, tail_d;
    logic                     tail_wrap_q, tail_wrap_d;

    logic    empty, full;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
`ifdef ROB_COMMIT_COUNTER
            commit_count_q <= 0;
`endif

            for (int i = 0; i < ROB_SIZE; i++) begin
                for (int j = 0; j < ROB_DISPATCH_WIDTH; j++) begin
                    entries_q[i][j] <= '0;
                end
            end

            head_q      <= '0;
            head_wrap_q <= '0;
            tail_q      <= '0;
            tail_wrap_q <= '0;
        end
        else begin
`ifdef ROB_COMMIT_COUNTER
            commit_count_q <= commit_count_d;
`endif

            entries_q   <= entries_d;
            head_q      <= head_d;
            head_wrap_q <= head_wrap_d;
            tail_q      <= tail_d;
            tail_wrap_q <= tail_wrap_d;
        end
    end

    always_comb begin
        logic cont;
        logic [COMMIT_WIDTH - 1:0] allow_commit;

        cont         = 1'b1;
        allow_commit = '0;

`ifdef ROB_COMMIT_COUNTER
        commit_count_d = commit_count_q;
`endif

        entries_d   = entries_q;
        head_d      = head_q;
        head_wrap_d = head_wrap_q;
        tail_d      = tail_q;
        tail_wrap_d = tail_wrap_q;

        empty = head_q == tail_q && head_wrap_q == tail_wrap_q;
        full  = head_q == tail_q && head_wrap_q != tail_wrap_q;

        rename_jump_commit_o = '0;
        dispatch_o           = '0;
        commit_o             = '0;
        rename_commit_o      = '0;
        jump_o               = '0;
        rob_write_valid_o    = '0;

        if (flush_i) begin
            head_d      = '0;
            head_wrap_d = '0;
            tail_d      = '0;
            tail_wrap_d = '0;
        end
        else begin
            if (!full) begin
                for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) begin
                    entries_d[head_q][i].valid  = dispatch_i[i].valid;
                    entries_d[head_q][i].busy   = 1'b1;
                    entries_d[head_q][i].except = 1'b0;

                    dispatch_o[i].ready = 1'b1;
                    dispatch_o[i].id    = rob_id_t'(head_q * ROB_DISPATCH_WIDTH + i);
                end

                if (head_q == INDEX_WIDTH'(ROB_SIZE - 1)) head_wrap_d = !head_wrap_q;
                head_d = INDEX_WIDTH'((head_q + INDEX_WIDTH'(1)) % SIZE_WIDTH'(ROB_SIZE));
            end

            for (int i = 0; i < ROB_COMMIT_WIDTH; i++) begin
                commit_o[i].ready = 1'b1;

                if (commit_i[i].valid) begin
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].busy       = 1'b0;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].jmp        = commit_i[i].jmp;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].mispred    = commit_i[i].mispred;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].jmp_target = commit_i[i].jmp_target;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].mem        = commit_i[i].mem;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].rd_a       = commit_i[i].rd_a;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].isa_rd     = commit_i[i].isa_addr;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].prev_rd    = commit_i[i].prev_addr;
                    entries_d
                        [commit_i[i].rob_id / ROB_DISPATCH_WIDTH]
                        [commit_i[i].rob_id % ROB_DISPATCH_WIDTH].rd         = commit_i[i].prf_addr;
                end
            end

            if (!empty) begin
                cont = 1'b1;

                for (int i = 0; i < COMMIT_WIDTH; i++) begin
                    if (cont && entries_q[tail_q][i].valid) begin
                        if (entries_q[tail_q][i].busy) begin
                            cont = 1'b0;
                        end
                        else begin
                            allow_commit[i] = 1'b1;

                            rename_commit_o[i].isa_addr  = entries_q[tail_q][i].isa_rd;
                            rename_commit_o[i].prev_addr = entries_q[tail_q][i].prev_rd;
                            rename_commit_o[i].prf_addr  = entries_q[tail_q][i].rd;

                            jump_o.target = entries_q[tail_q][i].jmp_target;

                            if (entries_q[tail_q][i].rd_a) begin
                                allow_commit[i] &= rename_commit_i[i].ready;

                                if (!rename_commit_i[i].ready) begin
                                    cont = 1'b0;
                                end
                            end

                            if (entries_q[tail_q][i].mispred) begin
                                allow_commit[i] &= jump_i.ready;

                                cont = 1'b0;
                            end

                            if (entries_q[tail_q][i].mem) begin
                                allow_commit[i] &= rob_write_ready_i;

                                cont = 0;
                            end

                            if (allow_commit[i]) begin
                                if (entries_q[tail_q][i].rd_a) begin
                                    rename_commit_o[i].valid = 1'b1;
                                end

                                if (entries_q[tail_q][i].mem) begin
                                    rob_write_valid_o = 1'b1;
                                end

                                if (entries_q[tail_q][i].mispred) begin
                                    jump_o.valid = 1'b1;
                                end

                                if (entries_q[tail_q][i].jmp) begin
                                    rename_jump_commit_o = 1'b1;
                                end

                                entries_d[tail_q][i].valid = 1'b0;
                            end
                        end
                    end
                end

                if (cont) begin
                    if (tail_q == INDEX_WIDTH'(ROB_SIZE - 1)) tail_wrap_d = !tail_wrap_q;
                    tail_d = INDEX_WIDTH'((tail_q + INDEX_WIDTH'(1)) % SIZE_WIDTH'(ROB_SIZE));
                end
            end
        end

`ifdef ROB_COMMIT_COUNTER
        for (int i = 0; i < COMMIT_WIDTH; i++) begin
            if (commit_i[i].valid && commit_o[i].ready) begin
                commit_count_d++;
            end
        end
`endif
    end

endmodule

