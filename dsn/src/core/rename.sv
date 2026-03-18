`include "config.svh"
`include "rename.svh"
`include "prf.svh"

module rename_m(
    input wire clk_i,
    input wire nrst_i,

    input  rename_dispatch_i_t [RENAME_WIDTH - 1:0] dispatch_i,
    output rename_dispatch_o_t [RENAME_WIDTH - 1:0] dispatch_o,

    input  rename_commit_i_t [COMMIT_WIDTH - 1:0] commit_i,
    output rename_commit_o_t [COMMIT_WIDTH - 1:0] commit_o,

    output prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_rel_o
);

    prf_addr_t freelist_head;
    logic [$clog2(PRF_SIZE + 1) - 1:0] freelist_size;
    prf_addr_t [PRF_SIZE - 1:0] freelist;

    rename_map_entry_t [REG_COUNT - 1:0] map_table;

    prf_addr_t [RENAME_WIDTH - 1:0] prf_addrs;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            freelist_head = 0;
            freelist_size = ($bits(freelist_size))'(PRF_SIZE);
            
            for (int i = 0; i < PRF_SIZE; i++) begin
                freelist[i] = PRF_ADDR_WIDTH'(i);
            end

            for (int i = 0; i < REG_COUNT; i++) begin
                map_table[i].valid = 0;
            end
        end
        else begin
            for (int i = 0; i < RENAME_WIDTH; i++) begin
                if (dispatch_i[i].valid && dispatch_o[i].ready) begin
                    prf_addr_t prf_addr;

                    if (dispatch_i[i].write) begin
                        prf_addr = freelist[freelist_head];

                        map_table[dispatch_i[i].isa_addr].prf_addr = prf_addr;
                        map_table[dispatch_i[i].isa_addr].valid = 1;

                        freelist_head = freelist_head + 1;
                        freelist_size = freelist_size - 1;
                    end
                    else begin
                        if (map_table[dispatch_i[i].isa_addr].valid) begin
                            prf_addr = map_table[dispatch_i[i].isa_addr].prf_addr;
                        end
                        else begin
                            prf_addr = freelist[freelist_head];

                            map_table[dispatch_i[i].isa_addr].prf_addr = prf_addr;
                            map_table[dispatch_i[i].isa_addr].valid = 1;

                            freelist_head = freelist_head + 1;
                            freelist_size = freelist_size - 1;
                        end
                    end

                    prf_addrs[i] = prf_addr;
                end
            end

            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                if (commit_i[i].valid && commit_o[i].ready) begin
                    freelist_head = freelist_head - 1;
                    freelist_size = freelist_size + 1;

                    if (map_table[commit_i[i].isa_addr].valid) begin
                        freelist[freelist_head] = map_table[commit_i[i].isa_addr].prf_addr;
                    end

                    map_table[commit_i[i].isa_addr].valid = 1;
                    map_table[commit_i[i].isa_addr].prf_addr = commit_i[i].prf_addr;
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < RENAME_WIDTH; i++) begin
            dispatch_o[i].prf_addr = prf_addrs[i];

            if (i < freelist_size) begin
                dispatch_o[i].ready = 1'b1;
            end
            else begin
                dispatch_o[i].ready = 1'b0;
            end
        end

        for (int i = 0; i < COMMIT_WIDTH; i++) begin
            commit_o[i].ready = 1'b1;
            
            if (map_table[commit_i[i].isa_addr].valid) begin
                prf_rel_o[i].rel  = commit_i[i].valid;

                prf_rel_o[i].addr = map_table[commit_i[i].isa_addr].prf_addr;
            end
        end
    end

endmodule
