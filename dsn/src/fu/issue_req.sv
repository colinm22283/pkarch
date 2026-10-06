`include "fu/issue_queue.svh"
`include "core/pc.svh"
`include "core/rob.svh"
`include "core/lsq.svh"
`include "fu/issue_queue.svh"
`include "isa.svh"

module issue_req_m(
    input logic clk_i,
    input logic nrst_i,

    input logic flush_i,

    input  iq_dispatch_i_t dispatch_i,
    output iq_dispatch_o_t dispatch_o,

    input  iq_acc_dispatch_o_t commit_i,
    output iq_acc_dispatch_i_t commit_o,

    input  prf_rport_req_o_t [1:0] rports_req_i,
    output prf_rport_req_i_t [1:0] rports_req_o,

    input  prf_wport_i_t [PRF_WPORTS - 1:0] prf_wport_i
);

    logic rs1_valid_q, rs1_valid_d;
    logic rs2_valid_q, rs2_valid_d;
    logic rs1_fwd_q, rs1_fwd_d;
    logic rs2_fwd_q, rs2_fwd_d;
    word_t rs1_q, rs1_d;
    word_t rs2_q, rs2_d;

    logic regs_valid;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            rs1_valid_q <= '0;
            rs2_valid_q <= '0;
            rs1_fwd_q   <= '0;
            rs2_fwd_q   <= '0;
            rs1_q       <= '0;
            rs2_q       <= '0;
        end
        else begin
            rs1_valid_q <= rs1_valid_d;
            rs2_valid_q <= rs2_valid_d;
            rs1_fwd_q   <= rs1_fwd_d;
            rs2_fwd_q   <= rs2_fwd_d;
            rs1_q       <= rs1_d;
            rs2_q       <= rs2_d;
        end
    end

    always_comb begin
        rs1_valid_d = rs1_valid_q;
        rs2_valid_d = rs2_valid_q;
        rs1_fwd_d   = rs1_fwd_q;
        rs2_fwd_d   = rs2_fwd_q;
        rs1_d       = rs1_q;
        rs2_d       = rs2_q;

        regs_valid = '0;

        dispatch_o   = '0;
        commit_o     = '0;
        rports_req_o = '0;

        rports_req_o[0].port   = 1'b0;
        rports_req_o[1].port   = 1'b1;
        rports_req_o[0].rob_id = dispatch_i.data.rob_id;
        rports_req_o[1].rob_id = dispatch_i.data.rob_id;
        rports_req_o[0].addr   = dispatch_i.data.rs1;
        rports_req_o[1].addr   = dispatch_i.data.rs2;

        if (flush_i) begin
            rs1_valid_d = '0;
            rs2_valid_d = '0;
            rs1_fwd_d   = '0;
            rs2_fwd_d   = '0;
        end
        else begin
            if (dispatch_i.valid) begin
                for (int i = 0; i < PRF_WPORTS; i++) begin
                    if (prf_wport_i[i].we && prf_wport_i[i].addr != PRF_ZERO_ADDR) begin
                        if (
                            !rs1_valid_d &&
                            prf_wport_i[i].addr == dispatch_i.data.rs1 &&
                            dispatch_i.data.dec_inst.rs1_a
                        ) begin
                            rs1_valid_d = 1'b1;
                            rs1_fwd_d   = 1'b1;
                            rs1_d       = prf_wport_i[i].data;
                        end

                        if (
                            !rs2_valid_d &&
                            prf_wport_i[i].addr == dispatch_i.data.rs2 &&
                            dispatch_i.data.dec_inst.rs2_a
                        ) begin
                            rs2_valid_d = 1'b1;
                            rs2_fwd_d   = 1'b1;
                            rs2_d       = prf_wport_i[i].data;
                        end
                    end
                end

                if (!rs1_valid_d && dispatch_i.data.dec_inst.rs1_a && dispatch_i.data.rs1 == PRF_ZERO_ADDR) begin
                    rs1_valid_d = 1'b1;
                    rs1_fwd_d   = 1'b1;
                    rs1_d       = '0;
                end

                if (!rs2_valid_d && dispatch_i.data.dec_inst.rs2_a && dispatch_i.data.rs2 == PRF_ZERO_ADDR) begin
                    rs2_valid_d = 1'b1;
                    rs2_fwd_d   = 1'b1;
                    rs2_d       = '0;
                end

                rports_req_o[0].req =
                    dispatch_i.data.rs1 != PRF_ZERO_ADDR &&
                    !rs1_valid_d &&
                    dispatch_i.data.dec_inst.rs1_a &&
                    (!rs2_valid_d && dispatch_i.data.dec_inst.rs2_a ? rports_req_i[1].ready : 'b1);

                rports_req_o[1].req =
                    dispatch_i.data.rs2 != PRF_ZERO_ADDR &&
                    !rs2_valid_d &&
                    dispatch_i.data.dec_inst.rs2_a &&
                    (!rs1_valid_d && dispatch_i.data.dec_inst.rs1_a ? rports_req_i[0].ready : 'b1);

                if (rports_req_o[0].req) rs1_valid_d = rports_req_i[0].ready;
                if (rports_req_o[1].req) rs2_valid_d = rports_req_i[1].ready;

                regs_valid = 1'b1;
                if (dispatch_i.data.dec_inst.rs1_a) regs_valid &= rs1_valid_d;
                if (dispatch_i.data.dec_inst.rs2_a) regs_valid &= rs2_valid_d;

                if (regs_valid && commit_i.ready) begin
                    commit_o.valid = 'b1;
                    commit_o.data  = dispatch_i.data;
                    commit_o.rs1_f = rs1_fwd_d;
                    commit_o.rs2_f = rs2_fwd_d;
                    commit_o.rs1   = rs1_d;
                    commit_o.rs2   = rs2_d;

                    dispatch_o.ready = 'b1;

                    rs1_valid_d = '0;
                    rs2_valid_d = '0;
                    rs1_fwd_d   = '0;
                    rs2_fwd_d   = '0;
                end
            end
        end
    end







    // logic rports_ready;

    // always_comb begin
        // rports_ready = 'b1;
        // if (dispatch_i.data.dec_inst.rs1_a) rports_ready &= rports_req_i[0].ready;
        // if (dispatch_i.data.dec_inst.rs2_a) rports_ready &= rports_req_i[1].ready;
    // end

    // assign rports_req_o[0].req =
            // dispatch_i.data.dec_inst.rs1_a &&
            // dispatch_i.valid &&
            // commit_i.ready &&
            // (dispatch_i.data.dec_inst.rs2_a ? rports_req_i[1].ready : 'b1);

    // assign rports_req_o[1].req =
            // dispatch_i.data.dec_inst.rs2_a &&
            // dispatch_i.valid &&
            // commit_i.ready &&
            // (dispatch_i.data.dec_inst.rs1_a ? rports_req_i[0].ready : 'b1);

    // always_comb begin
        // rports_req_o[0].port = 1'b0;
        // rports_req_o[1].port = 1'b1;

        // rports_req_o[0].rob_id = dispatch_i.data.rob_id;
        // rports_req_o[1].rob_id = dispatch_i.data.rob_id;

        // rports_req_o[0].addr = dispatch_i.data.rs1;
        // rports_req_o[1].addr = dispatch_i.data.rs2;

        // commit_o.valid = rports_ready && dispatch_i.valid;
        // commit_o.data  = dispatch_i.data;

        // dispatch_o.ready = rports_ready;
    // end

endmodule

