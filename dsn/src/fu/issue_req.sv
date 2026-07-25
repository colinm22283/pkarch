`include "fu/issue_queue.svh"

module issue_req_m(
    input logic clk_i,
    input logic nrst_i,

    input  iq_dispatch_i_t dispatch_i,
    output iq_dispatch_o_t dispatch_o,

    input  iq_dispatch_o_t commit_i,
    output iq_dispatch_i_t commit_o,

    input  prf_rport_req_o_t [1:0] rports_req_i,
    output prf_rport_req_i_t [1:0] rports_req_o
);

    

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
        end
        else begin
        end
    end

endmodule

