`include "fu/issue_queue.svh"
`include "core/pc.svh"
`include "core/rob.svh"
`include "isa.svh"
`include "config.svh"

module issue_queue_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  iq_dispatch_i_t [DISPATCH_WIDTH - 1:0] dispatch_i,
    output iq_dispatch_o_t [DISPATCH_WIDTH - 1:0] dispatch_o,

    input  iq_commit_i_t   [IQ_OUT_WIDTH - 1:0] commit_i,
    output iq_commit_o_t   [IQ_OUT_WIDTH - 1:0] commit_o,

    input  prf_rport_req_o_t [PRF_RPORTS - 1:0] rports_req_i,
    output prf_rport_req_i_t [PRF_RPORTS - 1:0] rports_req_o,
    input  prf_rport_ack_o_t [PRF_MEM_RPORTS - 1:0] rports_ack_i,
    output prf_rport_ack_i_t [PRF_MEM_RPORTS - 1:0] rports_ack_o,

    input  prf_wport_i_t [PRF_WPORTS - 1:0] prf_wport_i
);

    generate
        prf_rport_ack_i_t [PRF_MEM_RPORTS - 1:0] rports_acko [DISPATCH_WIDTH - 1:0];

        for (genvar i = 0; i < DISPATCH_WIDTH; i++) begin
            iq_dispatch_i_t dispatchi0;
            iq_dispatch_o_t dispatcho0;
            iq_acc_dispatch_i_t dispatchi1;
            iq_acc_dispatch_o_t dispatcho1;


            fifo_m #(
                .WIDTH($bits(iq_in_data_t)),
                .DEPTH(IQ_IN_SIZE),
                .FORWARDING(0)
            ) in_fifo(
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .flush_i(flush_i),

                .in_ready_o(dispatch_o[i].ready),
                .in_valid_i(dispatch_i[i].valid),
                .in_data_i(dispatch_i[i].data),

                .out_ready_i(dispatcho0.ready),
                .out_valid_o(dispatchi0.valid),
                .out_data_o(dispatchi0.data)
            );

            issue_req_m issue_req(
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .flush_i(flush_i),

                .dispatch_i(dispatchi0),
                .dispatch_o(dispatcho0),

                .commit_i(dispatcho1),
                .commit_o(dispatchi1),

                .rports_req_i(rports_req_i[i * 2+:2]),
                .rports_req_o(rports_req_o[i * 2+:2]),

                .prf_wport_i(prf_wport_i)
            );

            issue_acc_m issue_acc(
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .flush_i(flush_i),

                .dispatch_i(dispatchi1),
                .dispatch_o(dispatcho1),

                .commit_i(commit_i[i * IQ_COMMIT_WIDTH+:IQ_COMMIT_WIDTH]),
                .commit_o(commit_o[i * IQ_COMMIT_WIDTH+:IQ_COMMIT_WIDTH]),

                .rports_ack_i(rports_ack_i),
                .rports_ack_o(rports_acko[i])
            );
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < PRF_MEM_RPORTS; i++) begin
            rports_ack_o[i].ready = 1'b0;

            for (int j = 0; j < DISPATCH_WIDTH; j++) begin
                rports_ack_o[i].ready |= rports_acko[j][i];
            end
        end
    end

endmodule
