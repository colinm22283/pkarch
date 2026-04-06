`timescale 1ns/100ps

`include "dispatch.svh"
`include "rename.svh"
`include "rob.svh"
`include "fu.svh"
`include "logger.svh"

module dispatch_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  dispatch_i_t [DISPATCH_WIDTH - 1:0] dispatch_i,
    output dispatch_o_t [DISPATCH_WIDTH - 1:0] dispatch_o,

    input  rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_dispatch_i,
    output rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_dispatch_o,

    input  rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_i,
    output rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_o,

    input  res_dispatch_o_t [FU_COUNT - 1:0] res_dispatch_i,
    output res_dispatch_i_t [FU_COUNT - 1:0] res_dispatch_o
);

    `DL_DEFINE(log, "dispatch_m", `DL_BLUE, `DL_ENABLE_DISPATCH);

    res_dispatch_o_t res_dispatchi;
    res_dispatch_i_t res_dispatcho;

    always_comb begin
        for (int j = 0; j < DISPATCH_WIDTH; j++) begin
            res_dispatchi[j].ready = 0;

            for (int i = 0; i < FU_COUNT; i++) begin
                res_dispatchi[j].ready |= res_dispatch_i[i][j].ready;

                res_dispatch_o[i][j] = res_dispatcho[j];
            end
        end
    end

    dispatch_entry_t [DISPATCH_WIDTH - 1:0] entries;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                entries[i].valid <= 0;
            end
        end
        else begin
            logic [$clog2(RENAME_WIDTH + 1) - 1:0] rename_index;
            logic [$clog2(DISPATCH_WIDTH + 1) - 1:0] res_index;

            rename_index = 0;
            res_index = 0;

            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                if (flush_i) begin
                    entries[i].valid <= 0;
                end
                else begin
                    if (!entries[i].valid) begin
                        if (dispatch_i[i].valid) begin
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
                    else begin
                        if (!entries[i].rob_id_valid && rob_dispatch_i[i].ready) begin
                            entries[i].rob_id_valid <= 1;
                            entries[i].rob_id       <= rob_dispatch_i[i].id;

                            `DL(log, ("Alloc ROB ID of 0x%h", rob_dispatch_i[i].id));
                        end

                        if (
                            entries[i].dec_inst.rs1_a &&
                            !entries[i].rs1_valid &&
                            rename_index < RENAME_WIDTH &&
                            rename_dispatch_i[rename_index].ready
                        ) begin
                            entries[i].rs1_valid <= 1;
                            entries[i].rs1       <= rename_dispatch_i[rename_index].prf_addr;

                            `DL(log, ("Alloc RS1 (r%0d) at paddr 0x%h", entries[i].dec_inst.rs1, rename_dispatch_i[rename_index].prf_addr));

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

                            `DL(log, ("Alloc RS2 (r%0d) at paddr 0x%h", entries[i].dec_inst.rs2, rename_dispatch_i[rename_index].prf_addr));

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

                            `DL(log, ("Alloc RD (r%0d) at paddr 0x%h", entries[i].dec_inst.rd, rename_dispatch_i[rename_index].prf_addr));

                            rename_index++;
                        end

                        if (
                            entries[i].rob_id_valid &&
                            (entries[i].rs1_valid || !entries[i].dec_inst.rs1_a) &&
                            (entries[i].rs2_valid || !entries[i].dec_inst.rs2_a) &&
                            (entries[i].rd_valid  || !entries[i].dec_inst.rd_a) &&
                            res_index < DISPATCH_WIDTH &&
                            res_dispatchi[res_index].ready
                        ) begin
                            entries[i].valid <= 0;

                            res_index++;
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
        logic [$clog2(DISPATCH_WIDTH + 1) - 1:0] res_index;

        rename_index = 0;
        res_index = 0;

        for (int i = 0; i < RENAME_WIDTH; i++) begin
            rename_dispatch_o[i] = 0;
        end

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            rob_dispatch_o[i] = 0;

            res_dispatcho[i] = 0;
        end

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            if (!flush_i) begin
                if (entries[i].valid) begin
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
                        (entries[i].rd_valid  || !entries[i].dec_inst.rd_a) &&
                        res_index < DISPATCH_WIDTH
                    ) begin
                        res_dispatcho[res_index].valid = 1;

                        res_dispatcho[res_index].pc = entries[i].pc;

                        res_dispatcho[res_index].dec_inst = entries[i].dec_inst;

                        res_dispatcho[res_index].rob_id = entries[i].rob_id;

                        res_dispatcho[res_index].rs1 = entries[i].rs1;
                        res_dispatcho[res_index].rs2 = entries[i].rs2;
                        res_dispatcho[res_index].rd = entries[i].rd;

                        res_dispatcho[res_index].isa_addr = entries[i].dec_inst.rd;

                        res_index++;
                    end
                end
            end
        end
    end

endmodule

