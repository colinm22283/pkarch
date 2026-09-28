`timescale 1ns/100ps

`include "core/dispatch.svh"
`include "core/lsq.svh"
`include "core/rename.svh"
`include "core/rob.svh"
`include "fu/issue_queue.svh"
`include "test/logger.svh"

module dispatch_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    output logic rename_jump_o, // TODO: not implemented
    input  logic rename_jump_accept_i,

    /* verilator lint_on UNOPTFLAT */
    input  dispatch_i_t [DISPATCH_WIDTH - 1:0] dispatch_i,
    output dispatch_o_t [DISPATCH_WIDTH - 1:0] dispatch_o,
    /* verilator lint_off UNOPTFLAT */

    input  lsq_dispatch_o_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_i,
    output lsq_dispatch_i_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_o,

    input  rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_dispatch_i,
    output rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_dispatch_o,

    input  rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_i,
    output rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] rob_dispatch_o,

    input  iq_dispatch_o_t [DISPATCH_WIDTH - 1:0] iq_dispatch_i,
    output iq_dispatch_i_t [DISPATCH_WIDTH - 1:0] iq_dispatch_o
);

    `DL_DEFINE(log, "dispatch_m", `DL_BLUE, `DL_ENABLE_DISPATCH);

    logic entries_complete;
    dispatch_entry_t entries_q [DISPATCH_WIDTH - 1:0];
    dispatch_entry_t entries_d [DISPATCH_WIDTH - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) entries_q[i] <= '0;
        end
        else begin
            entries_q <= entries_d;
        end
    end

    always_comb begin
        logic [$clog2(LSQ_DISPATCH_WIDTH + 1) - 1:0] lsq_index;
        logic [$clog2(RENAME_WIDTH + 1) - 1:0] rename_index;
        logic cont;

        lsq_index    = '0;
        rename_index = '0;
        cont = 1'b1;

        entries_d = entries_q;

        dispatch_o = '0;

        for (int i = 0; i < LSQ_DISPATCH_WIDTH; i++) begin
            lsq_dispatch_o[i] = '0;
        end

        for (int i = 0; i < RENAME_WIDTH; i++) begin
            rename_dispatch_o[i] = '0;
        end

        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            rob_dispatch_o[i] = '0;

            iq_dispatch_o[i]  = '0;
        end

        rename_jump_o = 0;

        cont = 1'b1;

        if (flush_i) begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) entries_d[i].valid = 1'b0;

            entries_complete = 1'b0;
        end
        else begin
            for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                if (entries_d[i].valid && cont) begin
                    if (entries_d[i].rob_id_waiting && rob_dispatch_i[i].ready) begin
                        entries_d[i].rob_id_waiting = 1'b0;
                        entries_d[i].rob_id         = rob_dispatch_i[i].id;

                        rob_dispatch_o[i].valid = 1'b1;
                    end

                    if (
                        entries_d[i].lsq_waiting &&
                        lsq_index < LSQ_DISPATCH_WIDTH &&
                        lsq_dispatch_i[lsq_index].ready &&
                        !entries_d[i].rob_id_waiting
                    ) begin
                        entries_d[i].lsq_waiting = 1'b0;

                        lsq_dispatch_o[lsq_index].valid  = 1'b1;
                        lsq_dispatch_o[lsq_index].rob_id = entries_d[i].rob_id;
                        lsq_dispatch_o[lsq_index].rw     = entries_d[i].dec_inst.opcode == OPCODE_LOAD ? BUS_RW_READ : BUS_RW_WRITE;

                        lsq_index++;
                    end

                    if (entries_d[i].rs1_waiting && rename_index < RENAME_WIDTH) begin
                        entries_d[i].rs1_waiting = 1'b0;
                        entries_d[i].rs1         = rename_dispatch_i[rename_index].prf_addr;

                        rename_dispatch_o[rename_index].valid    = 1'b1;
                        rename_dispatch_o[rename_index].write    = 1'b0;
                        rename_dispatch_o[rename_index].isa_addr = entries_d[i].dec_inst.rs1;

                        rename_index++;
                    end

                    if (entries_d[i].rs2_waiting && rename_index < RENAME_WIDTH) begin
                        entries_d[i].rs2_waiting = 1'b0;
                        entries_d[i].rs2         = rename_dispatch_i[rename_index].prf_addr;

                        rename_dispatch_o[rename_index].valid    = 1'b1;
                        rename_dispatch_o[rename_index].write    = 1'b0;
                        rename_dispatch_o[rename_index].isa_addr = entries_d[i].dec_inst.rs2;

                        rename_index++;
                    end

                    if (entries_d[i].rd_waiting && rename_index < RENAME_WIDTH) begin
                        entries_d[i].rd_waiting = 1'b0;
                        entries_d[i].rd         = rename_dispatch_i[rename_index].prf_addr;
                        entries_d[i].prev_rd    = rename_dispatch_i[rename_index].prev_addr;

                        rename_dispatch_o[rename_index].valid    = 1'b1;
                        rename_dispatch_o[rename_index].write    = 1'b1;
                        rename_dispatch_o[rename_index].isa_addr = entries_d[i].dec_inst.rd;

                        rename_index++;
                    end

                    if (
                        !entries_d[i].rob_id_waiting &&
                        !entries_d[i].lsq_waiting &&
                        !entries_d[i].rs1_waiting &&
                        !entries_d[i].rs2_waiting &&
                        !entries_d[i].rd_waiting &&
                        iq_dispatch_i[i].ready
                    ) begin
                        entries_d[i].valid = 1'b0;

                        iq_dispatch_o[i].valid         = 1'b1;

                        iq_dispatch_o[i].data.pc       = entries_d[i].pc;

                        iq_dispatch_o[i].data.dec_inst = entries_d[i].dec_inst;

                        iq_dispatch_o[i].data.rob_id   = entries_d[i].rob_id;

                        iq_dispatch_o[i].data.rs1      = entries_d[i].rs1;
                        iq_dispatch_o[i].data.rs2      = entries_d[i].rs2;
                        iq_dispatch_o[i].data.rd       = entries_d[i].rd;
                        iq_dispatch_o[i].data.prev_rd  = entries_d[i].prev_rd;

                        iq_dispatch_o[i].data.isa_addr = entries_d[i].dec_inst.rd;
                    end
                    else cont = 1'b0;
                end
            end

            entries_complete = 1'b1;
            for (int i = 0; i < DISPATCH_WIDTH; i++) entries_complete &= !entries_d[i].valid;

            if (entries_complete) begin
                cont = 1'b1;

                for (int i = 0; i < DISPATCH_WIDTH; i++) begin
                    if (!dispatch_i[i].dec_inst.illegal && cont) begin
                        entries_d[i].valid    = dispatch_i[i].valid;
                        entries_d[i].pc       = dispatch_i[i].pc;
                        entries_d[i].dec_inst = dispatch_i[i].dec_inst;

                        entries_d[i].rob_id_waiting = 1'b1;
                        entries_d[i].lsq_waiting    = DEC_INST_IS_MEM(dispatch_i[i].dec_inst);
                        entries_d[i].rs1_waiting    = dispatch_i[i].dec_inst.rs1_a;
                        entries_d[i].rs2_waiting    = dispatch_i[i].dec_inst.rs2_a;
                        entries_d[i].rd_waiting     = dispatch_i[i].dec_inst.rd_a;
                    end
                    else cont = 1'b0;

                    dispatch_o[i].ready = 1'b1;
                end
            end
        end
    end

endmodule

