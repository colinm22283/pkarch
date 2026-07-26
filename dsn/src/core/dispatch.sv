`timescale 1ns/100ps

`include "core/dispatch.svh"
`include "core/rename.svh"
`include "core/rob.svh"
`include "fu/issue_queue.svh"
`include "test/logger.svh"

module dispatch_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    output logic rename_jump_o,
    input  logic rename_jump_accept_i,

    input  dispatch_i_t [DISPATCH_WIDTH - 1:0] dispatch_i,
    output dispatch_o_t [DISPATCH_WIDTH - 1:0] dispatch_o,

    input  rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_dispatch_i,
    output rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_dispatch_o,

    input  rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_i,
    output rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_o,

    input  iq_dispatch_o_t [DISPATCH_WIDTH - 1:0] iq_dispatch_i,
    output iq_dispatch_i_t [DISPATCH_WIDTH - 1:0] iq_dispatch_o
);

    `DL_DEFINE(log, "dispatch_m", `DL_BLUE, `DL_ENABLE_DISPATCH);

    logic entries_complete;
    dispatch_entry_t entries [DISPATCH_WIDTH - 1:0];

    logic [DISPATCH_WIDTH - 1:0] entry_jump;

    always_comb begin
        entries_complete = 1;
        for (int i = 0; i < DISPATCH_WIDTH; i++) entries_complete &= !entries[i].valid;
    end

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            entry_jump[i] =
                entries[i].dec_inst.opcode == OPCODE_BRANCH ||
                entries[i].dec_inst.opcode == OPCODE_LINK ||
                entries[i].dec_inst.opcode == OPCODE_LINKREG;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                entries[i].valid <= 0;
            end
        end
        else begin
            logic [$clog2(RENAME_WIDTH + 1) - 1:0] rename_index;

            rename_index = 0;

            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                if (flush_i) begin
                    entries[i].valid <= 0;
                end
                else begin
                    if (entries_complete) begin
                        if (dispatch_i[i].valid && ~dispatch_i[i].dec_inst.illegal) begin
                            `DL(log, ("NEW ENT: 0x%h", dispatch_i[i].dec_inst.opcode));
                            entries[i].valid <= 1;

                            entries[i].pc <= dispatch_i[i].pc;

                            entries[i].dec_inst <= dispatch_i[i].dec_inst;

                            entries[i].rob_id_valid <= 0;
                            entries[i].rs1_valid    <= 0;
                            entries[i].rs2_valid    <= 0;
                            entries[i].rd_valid     <= 0;
                        end
                    end
                    else if (entries[i].valid) begin
                        if (!entries[i].rob_id_valid && rob_dispatch_i[i].ready) begin
                            entries[i].rob_id_valid <= 1;
                            entries[i].rob_id       <= rob_dispatch_i[i].id;

                            `DL(log, ("Alloc ROB ID of 0x%h for instruction from 0x%h", rob_dispatch_i[i].id, entries[i].pc));
                        end

                        if (
                            entries[i].dec_inst.rs1_a &&
                            !entries[i].rs1_valid &&
                            rename_index < RENAME_WIDTH &&
                            rename_dispatch_i[rename_index].ready
                        ) begin
                            entries[i].rs1_valid <= 1;
                            entries[i].rs1       <= rename_dispatch_i[rename_index].prf_addr;

                            `DL(log, ("Alloc RS1 (%s) at paddr 0x%h", REG_NAME(entries[i].dec_inst.rs1), rename_dispatch_i[rename_index].prf_addr));

                            rename_index++;
                        end

                        if (
                            entries[i].dec_inst.rs2_a &&
                            !entries[i].rs2_valid &&
                            rename_index < RENAME_WIDTH &&
                            rename_dispatch_i[rename_index].ready
                        ) begin
                            entries[i].rs2_valid <= 1;
                            entries[i].rs2       <= rename_dispatch_i[rename_index].prf_addr;

                            `DL(log, ("Alloc RS2 (%s) at paddr 0x%h", REG_NAME(entries[i].dec_inst.rs2), rename_dispatch_i[rename_index].prf_addr));

                            rename_index++;
                        end

                        if (
                            entries[i].dec_inst.rd_a &&
                            !entries[i].rd_valid &&
                            rename_index < RENAME_WIDTH &&
                            rename_dispatch_i[rename_index].ready
                        ) begin
                            entries[i].rd_valid <= 1;
                            entries[i].rd       <= rename_dispatch_i[rename_index].prf_addr;
                            entries[i].prev_rd  <= rename_dispatch_i[rename_index].prev_addr;

                            `DL(log, ("Alloc RD (%s) at paddr 0x%h, with prev paddr 0x%x", REG_NAME(entries[i].dec_inst.rd), rename_dispatch_i[rename_index].prf_addr, rename_dispatch_i[rename_index].prev_addr));

                            rename_index++;
                        end

                        if (
                            entries[i].rob_id_valid &&
                            (entries[i].rs1_valid || !entries[i].dec_inst.rs1_a) &&
                            (entries[i].rs2_valid || !entries[i].dec_inst.rs2_a) &&
                            (entries[i].rd_valid  || !entries[i].dec_inst.rd_a) &&
                            iq_dispatch_i[i].ready
                        ) begin
                            if (entry_jump[i] ? rename_jump_accept_i : 1) begin
                                `DL(log, ("Instruction sent to reservation station"));

                                entries[i].valid <= 0;
                            end
                        end
                    end
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            if (flush_i) begin
                dispatch_o[i].ready = 0;
            end
            else begin
                if (!entries[i].valid) begin
                    dispatch_o[i].ready = 1;
                end
                else begin
                    dispatch_o[i].ready = 0;
                end
            end
        end
    end

    always_comb begin
        logic [$clog2(RENAME_WIDTH + 1) - 1:0] rename_index;

        rename_index = 0;

        for (int i = 0; i < RENAME_WIDTH; i++) begin
            rename_dispatch_o[i] = 0;
        end

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            rob_dispatch_o[i] = 0;

            iq_dispatch_o[i] = 0;
        end

        rename_jump_o = 0;

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            if (!flush_i) begin
                if (!rename_jump_o && entries[i].valid) begin
                    if (!entries[i].rob_id_valid) begin
                        rob_dispatch_o[i].valid = 1;
                    end

                    if (
                        entries[i].dec_inst.rs1_a &&
                        !entries[i].rs1_valid &&
                        rename_index < RENAME_WIDTH
                    ) begin
                        rename_dispatch_o[rename_index].valid    = 1;
                        rename_dispatch_o[rename_index].write    = 0;
                        rename_dispatch_o[rename_index].isa_addr = entries[i].dec_inst.rs1;

                        rename_index++;
                    end

                    if (
                        entries[i].dec_inst.rs2_a &&
                        !entries[i].rs2_valid &&
                        rename_index < RENAME_WIDTH
                    ) begin
                        rename_dispatch_o[rename_index].valid    = 1;
                        rename_dispatch_o[rename_index].write    = 0;
                        rename_dispatch_o[rename_index].isa_addr = entries[i].dec_inst.rs2;

                        rename_index++;
                    end

                    if (
                        entries[i].dec_inst.rd_a &&
                        !entries[i].rd_valid &&
                        rename_index < RENAME_WIDTH
                    ) begin
                        rename_dispatch_o[rename_index].valid    = 1;
                        rename_dispatch_o[rename_index].write    = 1;
                        rename_dispatch_o[rename_index].isa_addr = entries[i].dec_inst.rd;

                        rename_index++;
                    end

                    if (
                        entries[i].rob_id_valid &&
                        (entries[i].rs1_valid || !entries[i].dec_inst.rs1_a) &&
                        (entries[i].rs2_valid || !entries[i].dec_inst.rs2_a) &&
                        (entries[i].rd_valid  || !entries[i].dec_inst.rd_a)
                    ) begin
                        if (entry_jump[i]) rename_jump_o = 1;

                        if (entry_jump[i] ? rename_jump_accept_i : 1) begin
                            iq_dispatch_o[i].valid = 1;

                            iq_dispatch_o[i].data.pc = entries[i].pc;

                            iq_dispatch_o[i].data.dec_inst = entries[i].dec_inst;

                            iq_dispatch_o[i].data.rob_id = entries[i].rob_id;

                            iq_dispatch_o[i].data.rs1 = entries[i].rs1;
                            iq_dispatch_o[i].data.rs2 = entries[i].rs2;
                            iq_dispatch_o[i].data.rd = entries[i].rd;
                            iq_dispatch_o[i].data.prev_rd = entries[i].prev_rd;

                            iq_dispatch_o[i].data.isa_addr = entries[i].dec_inst.rd;
                        end
                    end
                end
            end
        end
    end

endmodule

