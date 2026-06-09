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

    output logic rename_jump_o,

    input  rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_i,
    output rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_o,

    input  rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] commit_i,
    output rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] commit_o,

    input  rename_commit_o_t [COMMIT_WIDTH - 1:0] rename_commit_i,
    output rename_commit_i_t [COMMIT_WIDTH - 1:0] rename_commit_o,

    input  fetch_jump_o_t jump_i,
    output fetch_jump_i_t jump_o,

    input  wire rob_write_ready_i,
    output wire rob_write_valid_o
);

    `DL_DEFINE(log, "rob_m", `DL_YELLOW, `DL_ENABLE_ROB);

    rob_id_t head, tail;
    logic [$clog2(ROB_SIZE + 1) - 1:0] size;

    rob_entry_t [ROB_SIZE - 1:0] entries;

    logic [COMMIT_WIDTH - 1:0] commit_entry;

    logic dispatch_any_valid;
    always_comb begin
        dispatch_any_valid = 0;
        for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) dispatch_any_valid |= dispatch_i[i].valid;
    end

    rob_id_t [ROB_DISPATCH_WIDTH - 1:0] rob_ids;

    logic dispatch_ready;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            head = 0;
            tail = 0;
            size = 0;
        end
        else begin
            if (flush_i) begin
                for (int i = 0; i < ROB_SIZE; i++) begin
                    entries[i].valid = 0;

                    head = 0;
                    tail = 0;
                    size = 0;
                end
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
                        `DL(log, (
                            "Marking rob entry %0d, jmp = %x",
                            commit_i[i].rob_id,
                            commit_i[i].jmp
                        ));

                        entries[commit_i[i].rob_id].busy = 0;
                        entries[commit_i[i].rob_id].jmp  = commit_i[i].jmp;
                        entries[commit_i[i].rob_id].jmp_target = commit_i[i].jmp_target;
                        entries[commit_i[i].rob_id].mem  = commit_i[i].mem;
                        entries[commit_i[i].rob_id].rd_a = commit_i[i].rd_a;
                        entries[commit_i[i].rob_id].isa_rd = commit_i[i].isa_addr;
                        entries[commit_i[i].rob_id].prev_rd = commit_i[i].prev_addr;
                    end
                end

                begin
                    rob_id_t old_head;
                    old_head = head;

                    for (int i = 0; i < COMMIT_WIDTH; i++) begin
                        rob_id_t index;

                        index = ROB_ID_WIDTH'((i + 32'(old_head)) % ROB_SIZE);

                        if (commit_entry[i]) begin
                            `DL(log, (
                                "Committing entry 0x%x, rd_a = %x, isa_rd = r%0d, prev_rd = 0x%x, mem = %x, jmp = %x",
                                index,
                                entries[index].rd_a,
                                entries[index].isa_rd,
                                entries[index].prev_rd,
                                entries[index].mem,
                                entries[index].jmp
                            ));

                            entries[index].valid = 0;

                            size = size - 1;
                            head = head + 1;
                        end
                    end
                end
            end
        end
    end

    logic mem, rd_a, jmp;

    assign mem = entries[head].mem;
    assign rd_a = entries[head].rd_a;
    assign jmp = entries[head].jmp;

    logic mem1, rd_a1, jmp1;

    assign mem1 = entries[head + 1].mem;
    assign rd_a1 = entries[head + 1].rd_a;
    assign jmp1 = entries[head + 1].jmp;

    logic evalid;
    assign evalid = entries[head].valid;

    logic evalid1;
    assign evalid1 = entries[head + 1].valid;

    logic ebusy;
    assign ebusy = entries[head].busy;

    logic ebusy1;
    assign ebusy1 = entries[head + 1].busy;

    always_comb begin
        logic cont;
        rob_id_t index;

        jump_o = 0;

        cont = 1;
        index = 0;

        dispatch_ready = size != ROB_SIZE; // TODO

        rob_ids = 0;

        rename_jump_o = 0;

        if (dispatch_any_valid) begin
            for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) begin
                rob_ids[i] = tail + ($bits(rob_id_t))'(i);
            end
        end

        for (int i = 0; i < ROB_DISPATCH_WIDTH; i++) begin
            dispatch_o[i].ready = dispatch_ready && !flush_i;
            dispatch_o[i].id    = rob_ids[i];
        end

        for (int i = 0; i < ROB_COMMIT_WIDTH; i++) begin
            commit_o[i].ready = !flush_i;
        end

        rename_commit_o = 0;
        commit_entry = 0;
        rob_write_valid_o = 0;

        if (!flush_i) begin
            for (int i = 0; i < COMMIT_WIDTH; i++) begin
                if (i < size && cont) begin
                    index = ROB_ID_WIDTH'((i + 32'(head)) % ROB_SIZE);

                    cont = 0;

                    if (entries[index].valid && !entries[index].busy) begin
                        commit_entry[i] = 1;

                        cont = 1;

                        if (entries[index].rd_a) begin
                            rename_commit_o[i].isa_addr = entries[index].isa_rd;
                            rename_commit_o[i].prev_addr = entries[index].prev_rd;

                            commit_entry[i] &= rename_commit_i[i].ready;

                            if (!rename_commit_i[i].ready) begin
                                // commit_entry[i] = 0;

                                cont = 0;
                            end
                        end

                        if (entries[index].jmp) begin
                            jump_o.target = entries[index].jmp_target;

                            commit_entry[i] &= jump_i.ready;

                            cont = 0;
                        end

                        if (entries[index].mem) begin
                            commit_entry[i] &= rob_write_ready_i;

                            cont = 0;
                        end

                        if (commit_entry[i]) begin
                            if (entries[index].rd_a) begin
                                rename_commit_o[i].valid = 1;
                            end

                            if (entries[index].mem) begin
                                rob_write_valid_o = 1;
                            end

                            if (entries[index].jmp) begin
                                jump_o.valid = 1;

                                rename_jump_o = 1;
                            end
                        end
                    end
                end
            end
        end
    end

endmodule
