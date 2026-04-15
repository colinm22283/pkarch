`timescale 1ns/100ps

`include "config.svh"
`include "rob.svh"
`include "rename.svh"
`include "fetch.svh"

module rob_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  bus_miport_t [MEMORY_PORTS - 1:0] mports_i,
    output bus_moport_t [MEMORY_PORTS - 1:0] mports_o,

    input  rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_i,
    output rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] dispatch_o,

    input  rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] commit_i,
    output rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] commit_o,

    input  rename_commit_o_t [COMMIT_WIDTH - 1:0] rename_commit_i,
    output rename_commit_i_t [COMMIT_WIDTH - 1:0] rename_commit_o,

    input  fetch_jump_o_t jump_i,
    output fetch_jump_i_t jump_o
);

    `DL_DEFINE(log, "rob_m", `DL_YELLOW, `DL_ENABLE_ROB);

    rob_id_t head, tail;
    logic [$clog2(ROB_SIZE + 1) - 1:0] size;

    rob_entry_t [ROB_SIZE - 1:0] entries;

    logic [ROB_SIZE - 1:0] commit_entry;

    logic [$clog2(MEMORY_PORTS) - 1:0] mem_unit [ROB_SIZE - 1:0];
    enum {
        MEM_STATE_IDLE,
        MEM_STATE_RUN
    } mem_states [MEMORY_PORTS - 1:0];

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
            if (flush_i) begin
                for (int i = 0; i < ROB_SIZE; i++) begin
                    entries[i].valid = 0;

                    head <= 0;
                    tail <= 0;
                    size <= 0;
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
                        entries[commit_i[i].rob_id].busy = 0;
                        entries[commit_i[i].rob_id].jmp  = commit_i[i].jmp;
                        entries[commit_i[i].rob_id].jmp_target = commit_i[i].jmp_target;
                        entries[commit_i[i].rob_id].rd_a = commit_i[i].rd_a;
                        entries[commit_i[i].rob_id].isa_rd = commit_i[i].isa_addr;
                        entries[commit_i[i].rob_id].prev_rd = commit_i[i].prev_addr;
                    end
                end

                for (int i = 0; i < COMMIT_WIDTH; i++) begin
                    rob_id_t index;

                    index = ROB_ID_WIDTH'((i + 32'(head)) % ROB_SIZE);

                    if (commit_entry[i]) begin
                        `DL(log, (
                            "committed entry 0x%x, rd_a = %x, isa_rd = r%0d, prev_rd = 0x%x",
                            index,
                            entries[index].rd_a,
                            entries[index].isa_rd,
                            entries[index].prev_rd
                        ));

                        entries[index].valid = 0;

                        size = size - 1;
                        head = head + 1;
                    end
                end
            end
        end
    end

    always_comb begin
        logic cont;
        rob_id_t index;
        logic [$clog2(MEMORY_PORTS + 1) - 1:0] memory_commits;

        jump_o = 0;

        cont = 1;
        index = 0;
        memory_commits = 0;

        dispatch_ready = size != ROB_SIZE;

        rob_ids = 0;

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

                            if (!rename_commit_i[i].ready) begin
                                commit_entry[i] = 0;

                                cont = 0;
                            end
                        end

                        if (entries[index].mem) begin
                            if (memory_commits < MEMORY_PORTS) begin
                                if (mem_states[memory_commits]

                                memory_commits = memory_commits + 1;
                            end
                        end

                        if (entries[index].jmp) begin
                            jump_o.target = entries[index].jmp_target;

                            cont = 0;

                            if (!jump_i.ready) begin
                                commit_entry[i] = 0;

                            end
                        end

                        if (commit_entry[i]) begin
                            if (entries[index].rd_a) begin
                                rename_commit_o[i].valid = 1;
                            end

                            if (entries[index].jmp) begin
                                jump_o.valid = 1;
                            end
                        end
                    end
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < MEMORY_PORTS; i++) begin
                mports_o[i] = 0;
            end
        end
        else begin
        end
    end

endmodule
