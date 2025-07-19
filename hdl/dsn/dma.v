`include "defs.v"

module dma_m #(
    parameter ADDRESS = 0
) (
    input wire clk_i,
    input wire nrst_i,

    input  wire [`BUS_PORT] port_i,
    output wire [`BUS_PORT] port_o
);

    wire        req;
    wire        ack;
    wire        rw;
    wire [1:0]  size;
    wire [31:0] addr;
    wire [31:0] datai;
    reg  [31:0] datao;
    
    busterm_m #(ADDRESS, SIZE) terminator(
        .port_i(port_i),
        .port_o(port_o),

        .req_i(1'b0),
        .ack_o(),

        .req_o(req),
        .ack_i(ack),

        .rw_i(1'b0),
        .size_i(2'b0),

        .rw_o(rw),
        .size_o(size),

        .addr_o(addr),
        .addr_i(32'b0),

        .data_o(datai),
        .data_i(datao)
    );

    reg run;
    reg running;

    always @(posedge clk_i, negedge nrst_i) begin
        if (!nrst_i) begin
        end
        else if (clk_i) begin
        end
    end

endmodule
