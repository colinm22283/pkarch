`include "fu/issue_queue.svh"

module issue_acc_m(
    input  logic clk_i,
    input  logic nrst_i,

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

    entry_t entries     [IQ_ACC_SIZE - 1:0];
    logic   entry_ready [IQ_ACC_SIZE - 1:0];

    logic [$clog2(IQ_ACC_SIZE) - 1:0] accept_addr;
    logic [$clog2(IQ_ACC_SIZE) - 1:0] rport_addr [PRF_MEM_RPORTS - 1:0];

    logic [IQ_ACC_SIZE - 1:0] commit_entry;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                entries[i].valid = 0;
            end
        end
        else begin
            if (dispatch_o.ready) begin
                entries[accept_addr].valid <= 1;

                entries[accept_addr].rs1 = dispatch_i.data.dec_inst.rs1_a;
                entries[accept_addr].rs2 = dispatch_i.data.dec_inst.rs2_a;
                entries[accept_addr].data = dispatch_i.data;
            end

            for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
                if (rports_ack_o[i].ready) begin
                    if (rports_ack_i[i].port == 1'b0) begin
                        entries[rport_addr[i]].rs1_v <= rports_ack_i[i].data;
                        entries[rport_addr[i]].rs1   <= 0;
                    end
                    else begin
                        entries[rport_addr[i]].rs2_v <= rports_ack_i[i].data;
                        entries[rport_addr[i]].rs2   <= 0;
                    end
                end
            end

            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                if (commit_entry[i]) begin
                    entries[i].valid <= 1'b0;
                end
            end
        end
    end

    always_comb begin
        logic cont;
        cont = 1;

        dispatch_o.ready = 1'b0;

        accept_addr = '0;

        if (dispatch_i.valid) begin
            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                if (cont && !entries[i].valid) begin
                    dispatch_o.ready = 1;

                    accept_addr = $clog2(IQ_ACC_SIZE)'(i);

                    cont = 0;
                end
            end
        end

        for (int i = 0; i < IQ_ACC_SIZE; i++) begin
            rport_addr[i] = '0;
        end

        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            rports_ack_o[i].ready = 1'b0;

            for (int j = 0; j < IQ_ACC_SIZE; j++) begin
                if (rports_ack_i[i].ack) begin
                    if (
                        (rports_ack_i[i].port ? entries[j].rs2 : entries[j].rs1) &&
                        rports_ack_i[i].rob_id == entries[j].data.rob_id
                    ) begin
                        rports_ack_o[i].ready = 1'b1;
                        rport_addr[i]         = $clog2(IQ_ACC_SIZE)'(j);
                    end
                end
            end
        end

        for (int i = 0; i < IQ_ACC_SIZE; i++) begin
            entry_ready[i] =
                entries[i].valid &&
                !entries[i].rs1 &&
                !entries[i].rs2;
        end

        begin
            logic [$clog2(IQ_COMMIT_WIDTH + 1) - 1:0] commit_port;
            commit_port = 0;

            for (int i = 0; i < IQ_COMMIT_WIDTH; i++) begin
                commit_o[i] = '0;
            end

            for (int i = 0; i < IQ_ACC_SIZE; i++) begin
                if (commit_port != IQ_COMMIT_WIDTH && entry_ready[i]) begin
                    commit_entry[i] = commit_i[commit_port].ready;

                    commit_o[commit_port].valid = 1'b1;
                    commit_o[commit_port].data.pc = entries[i].data.pc;
                    commit_o[commit_port].data.dec_inst = entries[i].data.dec_inst;
                    commit_o[commit_port].data.rob_id = entries[i].data.rob_id;
                    commit_o[commit_port].data.rd = entries[i].data.rd;
                    commit_o[commit_port].data.prev_rd = entries[i].data.prev_rd;
                    commit_o[commit_port].data.isa_addr = entries[i].data.isa_addr;
                    commit_o[commit_port].data.rs1_v = entries[i].rs1_v;
                    commit_o[commit_port].data.rs2_v = entries[i].rs2_v;

                    commit_port++;
                end
                else begin
                    commit_entry[i] = 1'b0;
                end
            end
        end
    end

endmodule

