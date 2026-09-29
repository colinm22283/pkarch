`timescale 1ns/100ps

`include "fu/issue_queue.svh"
`include "core/pc.svh"
`include "core/rob.svh"
`include "core/lsq.svh"
`include "fu/issue_queue.svh"
`include "isa.svh"

module issue_acc_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  iq_dispatch_i_t dispatch_i,
    output iq_dispatch_o_t dispatch_o,

    input  iq_commit_i_t [IQ_COMMIT_WIDTH - 1:0] commit_i,
    output iq_commit_o_t [IQ_COMMIT_WIDTH - 1:0] commit_o,

    input  prf_rport_ack_o_t [PRF_MEM_RPORTS - 1:0] rports_ack_i,
    output prf_rport_ack_i_t [PRF_MEM_RPORTS - 1:0] rports_ack_o
);

    typedef struct packed {
        bit valid;

        bit    rs1, rs2;
        word_t rs1_v, rs2_v;

        iq_in_data_t data;
    } entry_t;

    entry_t entries_q [IQ_ACC_SIZE - 1:0];
    entry_t entries_d [IQ_ACC_SIZE - 1:0];

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                entries_q[i].valid <= '0;
            end
        end
        else begin
            entries_q <= entries_d;
        end
    end

always_comb begin
        logic cont;

        cont = 1'b0;

        entries_d = entries_q;

        dispatch_o   = '0;
        commit_o     = '0;
        rports_ack_o = '0;

        if (flush_i) begin
            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                entries_d[i].valid = '0;
            end
        end
        else begin
            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                if (entries_d[i].valid) begin
                    for (int j = 0; j < PRF_MEM_RPORTS; j++) begin
                        if (
                            rports_ack_i[j].ack &&
                            (rports_ack_i[j].port ? entries_d[i].rs2 : entries_d[i].rs1) &&
                            rports_ack_i[j].rob_id == entries_d[i].data.rob_id
                        ) begin
                            rports_ack_o[j].ready = 1'b1;

                            if (rports_ack_i[j].port == 1'b0) begin
                                entries_d[i].rs1_v = rports_ack_i[j].data;
                                entries_d[i].rs1   = 1'b0;
                            end
                            else begin
                                entries_d[i].rs2_v = rports_ack_i[j].data;
                                entries_d[i].rs2   = 1'b0;
                            end
                        end
                    end

                    commit_o[i].data.pc       = entries_d[i].data.pc;
                    commit_o[i].data.dec_inst = entries_d[i].data.dec_inst;
                    commit_o[i].data.rob_id   = entries_d[i].data.rob_id;
                    commit_o[i].data.rd       = entries_d[i].data.rd;
                    commit_o[i].data.prev_rd  = entries_d[i].data.prev_rd;
                    commit_o[i].data.isa_addr = entries_d[i].data.isa_addr;
                    commit_o[i].data.rs1_v    = entries_d[i].rs1_v;
                    commit_o[i].data.rs2_v    = entries_d[i].rs2_v;

                    if (!entries_d[i].rs1 && !entries_d[i].rs2) begin
                        commit_o[i].valid         = 1'b1;

                        if (commit_i[i].ready) begin
                            entries_d[i].valid = 1'b0;
                        end
                    end
                end
            end

            dispatch_o.ready = 1'b0;
            for (int i = 0; i < IQ_ACC_SIZE; i++) dispatch_o.ready |= !entries_d[i].valid;
            if (dispatch_i.valid) begin
                cont = 1'b1;

                for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                    if (cont && !entries_d[i].valid) begin
                        entries_d[i].valid = 1'b1;

                        entries_d[i].rs1   = dispatch_i.data.dec_inst.rs1_a && !dispatch_i.rs1_f;
                        entries_d[i].rs1_v = dispatch_i.rs1;
                        entries_d[i].rs2   = dispatch_i.data.dec_inst.rs2_a && !dispatch_i.rs2_f;
                        entries_d[i].rs2_v = dispatch_i.rs2;
                        entries_d[i].data  = dispatch_i.data;

                        cont = 1'b0;
                    end
                end
            end
        end
    end

endmodule

