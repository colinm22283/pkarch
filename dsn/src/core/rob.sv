`timescale 1ns/100ps

`include "config.svh"
`include "rob.svh"
`include "rename.svh"

module rob_m(
    input wire clk_i,
    input wire nrst_i,

    input  rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_i,
    output rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_o,

    input  rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] commit_i,
    output rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] commit_o,

    input  rename_commit_o_t [COMMIT_WIDTH - 1:0] rename_commit_i,
    output rename_commit_i_t [COMMIT_WIDTH - 1:0] rename_commit_o
);

    rob_id_t head, tail;
    logic [$clog2(ROB_SIZE + 1) - 1:0] size;

    rob_entry_t [ROB_SIZE - 1:0] entries;

    logic [ROB_SIZE - 1:0] commit_entry;

    logic dispatch_any_valid;
    always_comb begin
        dispatch_any_valid = 0;
        for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) dispatch_any_valid |= dispatch_i[i].valid;
    end

    rob_id_t [ROB_DISPATCH_WIDTH - 1:0] rob_ids;

    logic dispatch_ready;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head <= 0;
            tail <= 0;
            size <= 0;
        end
        else begin
            if (dispatch_any_valid) begin
                for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) begin
                    if (dispatch_i[i].valid) begin
                        entries[tail].valid  = 1;
                        entries[tail].busy   = 1;
                        entries[tail].except = 0;
                    end
                    else begin
                        entries[tail].valid = 0;
                    end

                    size = size + 1;
                    tail = tail + 1;
                end
            end

            for (int i = 0; i < ROB_COMMIT_WIDTH; i++) begin
                if (commit_i[i].valid) begin
                    entries[commit_i[i].rob_id].busy = 0;
                    entries[commit_i[i].rob_id].jmp  = commit_i[i].jmp;
                    entries[commit_i[i].rob_id].jmp_target = commit_i[i].jmp_target;
                    entries[commit_i[i].rob_id].rd_a = commit_i[i].rd_a;
                    entries[commit_i[i].rob_id].isa_rd = commit_i[i].isa_addr;
                    entries[commit_i[i].rob_id].prf_rd = commit_i[i].prf_addr;
                end
            end

            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                rob_id_t index;

                index = ROB_ID_WIDTH'((i + 32'(head)) % ROB_SIZE);

                if (commit_entry[i]) begin
                    entries[index].valid = 0;

                    size = size - 1;
                    head = head + 1;
                end
            end
        end
    end

    always_comb begin
        logic cont;
        rob_id_t index;

        cont = 1;
        index = 0;

        dispatch_ready = size != ROB_SIZE;

        rob_ids = 0;

        if (dispatch_any_valid) begin
            for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) begin
                rob_ids[i] = tail + ($bits(rob_id_t))'(i);
            end
        end

        for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) begin
            dispatch_o[i].ready = dispatch_ready;
            dispatch_o[i].id    = rob_ids[i];
        end

        for (int i = 0; i < ROB_COMMIT_WIDTH; i++) begin
            commit_o[i].ready = 1;
        end

        rename_commit_o = 0;
        commit_entry = 0;

        for (int i = 0; i < COMMIT_WIDTH; i++) begin
            if (i < size && cont) begin
                index = ROB_ID_WIDTH'((i + 32'(head)) % ROB_SIZE);

                cont = 0;

                if (entries[index].valid && !entries[index].busy) begin
                    if (entries[index].rd_a) begin
                        rename_commit_o[i].valid = rename_commit_i[i].ready;
                        rename_commit_o[i].isa_addr = entries[index].isa_rd;
                        rename_commit_o[i].prf_addr = entries[index].prf_rd;

                        commit_entry[i] = rename_commit_i[i].ready;
                    end
                    else begin
                        commit_entry[i] = 1;
                    end

                    cont = 1;
                end
            end
        end
    end

endmodule
