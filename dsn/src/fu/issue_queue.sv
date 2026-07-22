

module issue_queue_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  iq_dispatch_i_t dispatch_i,
    output iq_dispatch_o_t dispatch_o
);

    fifo_m #(
        .WIDTH($bits(iq_in_data_t)),
        .DEPTH(IQ_IN_SIZE)
    ) in_fifo(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .in_ready_o(dispatch_o.ready),
        .in_valid_i(dispatch_i.valid),
        .in_data_i(dispatch_i.data),

        .out_ready_i(1'b0),
        .out_valid_o(),
        .out_data_o()
    );

endmodule
