`include "fu/issue_queue.svh"

module issue_req_m(
    input logic clk_i,
    input logic nrst_i,

    input logic flush_i,

    input  iq_dispatch_i_t dispatch_i,
    output iq_dispatch_o_t dispatch_o,

    input  iq_dispatch_o_t commit_i,
    output iq_dispatch_i_t commit_o,

    input  prf_rport_req_o_t [1:0] rports_req_i,
    output prf_rport_req_i_t [1:0] rports_req_o
);

    logic rports_ready;

    always_comb begin
        rports_ready = 'b1;
        if (dispatch_i.data.dec_inst.rs1_a) rports_ready &= rports_req_i[0].ready;
        if (dispatch_i.data.dec_inst.rs2_a) rports_ready &= rports_req_i[1].ready;
    end

    assign rports_req_o[0].req =
            dispatch_i.data.dec_inst.rs1_a &&
            dispatch_i.valid &&
            commit_i.ready &&
            (dispatch_i.data.dec_inst.rs2_a ? rports_req_i[1].ready : 'b1);

    assign rports_req_o[1].req =
            dispatch_i.data.dec_inst.rs2_a &&
            dispatch_i.valid &&
            commit_i.ready &&
            (dispatch_i.data.dec_inst.rs1_a ? rports_req_i[0].ready : 'b1);

    always_comb begin
        rports_req_o[0].port = 1'b0;
        rports_req_o[1].port = 1'b1;

        rports_req_o[0].rob_id = dispatch_i.data.rob_id;
        rports_req_o[1].rob_id = dispatch_i.data.rob_id;

        rports_req_o[0].addr = dispatch_i.data.rs1;
        rports_req_o[1].addr = dispatch_i.data.rs2;

        commit_o.valid = rports_ready && dispatch_i.valid;
        commit_o.data  = dispatch_i.data;

        dispatch_o.ready = rports_ready;

    end

endmodule

