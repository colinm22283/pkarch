`include "config.svh"
`include "rename.svh"
`include "prf.svh"
`include "logger.svh"

module rename_m(
    input wire clk_i,
    input wire nrst_i,

    input  wire flush_i,
    output wire flush_complete_o,

    input  rename_dispatch_i_t [RENAME_WIDTH - 1:0] dispatch_i,
    output rename_dispatch_o_t [RENAME_WIDTH - 1:0] dispatch_o,

    input  rename_commit_i_t [COMMIT_WIDTH - 1:0] commit_i,
    output rename_commit_o_t [COMMIT_WIDTH - 1:0] commit_o,

    output prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_rel_o
);

    `DL_DEFINE(log, "rename_m", `DL_CYAN, `DL_ENABLE_RENAME);

    prf_addr_t committed_freelist_head;
    logic [$clog2(PRF_SIZE + 1) - 1:0] committed_freelist_size;
    prf_addr_t [PRF_SIZE - 1:0] committed_freelist;

    rename_map_entry_t [REG_COUNT - 1:0] committed_map_table;

    prf_addr_t freelist_head;
    logic [$clog2(PRF_SIZE + 1) - 1:0] freelist_size;
    prf_addr_t [PRF_SIZE - 1:0] freelist;

    rename_map_entry_t [REG_COUNT - 1:0] map_table;

    prf_addr_t [RENAME_WIDTH - 1:0] prf_addrs;

    logic flushing;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            freelist_head = 0;
            freelist_size = ($bits(freelist_size))'(PRF_SIZE);

            committed_freelist_head = 0;
            committed_freelist_size = ($bits(freelist_size))'(PRF_SIZE);
            
            for (int i = 0; i < PRF_SIZE; i++) begin
                freelist[i] = PRF_ADDR_WIDTH'(i);
                committed_freelist[i] = PRF_ADDR_WIDTH'(i);
            end

            for (int i = 0; i < REG_COUNT; i++) begin
                map_table[i].valid = 0;
                committed_map_table[i].valid = 0;
            end

            flushing = 0;
        end
        else begin
            if (flushing) begin
                flushing = 0;
            end
            else if (flush_i) begin
                flushing = 1;
            end else begin
                for (int i = 0; i < RENAME_WIDTH; i++) begin
                    if (dispatch_i[i].valid && dispatch_o[i].ready && dispatch_i[i].isa_addr != REG_ZERO) begin
                        if (dispatch_i[i].write) begin
                            `DL(log, ("r%0d valid", dispatch_i[i].isa_addr));
                            map_table[dispatch_i[i].isa_addr].prf_addr = prf_addrs[i];
                            map_table[dispatch_i[i].isa_addr].valid = 1;

                            freelist_head = freelist_head + 1;
                            freelist_size = freelist_size - 1;
                        end
                        else begin
                            if (!map_table[dispatch_i[i].isa_addr].valid) begin
                                $finish;

                                map_table[dispatch_i[i].isa_addr].prf_addr = prf_addrs[i];
                                map_table[dispatch_i[i].isa_addr].valid = 1;

                                freelist_head = freelist_head + 1;
                                freelist_size = freelist_size - 1;
                            end
                        end
                    end
                end

                for (int i = 0; i < COMMIT_WIDTH; i++) begin
                    if (commit_i[i].valid && commit_o[i].ready && commit_i[i].isa_addr != REG_ZERO) begin
                        if (
                            map_table[commit_i[i].isa_addr].valid &&
                            commit_i[i].prev_addr != PRF_ZERO_ADDR
                        ) begin
                            `DL(log, ("release r%0d, returning 0x%x to freelist", commit_i[i].isa_addr, commit_i[i].prev_addr));
                            freelist_head = freelist_head - 1;
                            freelist_size = freelist_size + 1;

                            freelist[freelist_head] = commit_i[i].prev_addr;
                        end
                    end
                end
            end
        end
    end

    assign flush_complete_o = flush_i;

    always_comb begin
        for (int i = 0; i < RENAME_WIDTH; i++) begin
            if (dispatch_i[i].valid && i < freelist_size) begin : TEST
                if (dispatch_i[i].write) begin
                    prf_addrs[i] = freelist[freelist_head];
                end
                else begin
                    if (map_table[dispatch_i[i].isa_addr].valid) begin
                        prf_addrs[i] = map_table[dispatch_i[i].isa_addr].prf_addr;
                    end
                    else begin
                        prf_addrs[i] = freelist[freelist_head];
                    end
                end
            end
            else begin
                prf_addrs[i] = 0;
            end
        end

        for (int i = 0; i < RENAME_WIDTH; i++) begin
            if (dispatch_i[i].isa_addr != REG_ZERO) begin
                dispatch_o[i].prf_addr = prf_addrs[i];

                if (map_table[dispatch_i[i].isa_addr].valid) begin
                    dispatch_o[i].prev_addr = map_table[dispatch_i[i].isa_addr].prf_addr;
                end
                else begin
                    dispatch_o[i].prev_addr = PRF_ZERO_ADDR;
                end

                if (i < freelist_size) begin
                    dispatch_o[i].ready = 1'b1;
                end
                else begin
                    dispatch_o[i].ready = 1'b0;
                end
            end
            else begin
                dispatch_o[i].prf_addr  = PRF_ZERO_ADDR;
                dispatch_o[i].prev_addr = PRF_ZERO_ADDR;
                dispatch_o[i].ready     = 1'b1;
            end
        end

        for (int i = 0; i < COMMIT_WIDTH; i++) begin
            commit_o[i].ready = 1'b1;

            prf_rel_o[i] = 0;
            
            if (commit_i[i].isa_addr != REG_ZERO && commit_i[i].prev_addr != PRF_ZERO_ADDR) begin
                if (
                    map_table[commit_i[i].isa_addr].valid
                ) begin
                    prf_rel_o[i].rel  = commit_i[i].valid;

                    prf_rel_o[i].addr = commit_i[i].prev_addr;
                end
            end
        end
    end

endmodule
