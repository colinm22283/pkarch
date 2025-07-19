`include "defs.v"

module ram_m #(
    parameter ADDRESS = 0,
    parameter SIZE = 1
) (
    input wire clk_i,
    input wire nrst_i,

    input  wire [`BUS_PORT] port_i,
    output wire [`BUS_PORT] port_o
);

    reg [7:0] mem [SIZE - 1:0];
    initial begin : MEM_INIT
        integer i;

        for (i = 0; i < SIZE; i = i + 1) mem[i] <= i;
    end

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
    
    localparam STATE_READY = 3'b000;
    localparam STATE_BIT0  = 3'b001;
    localparam STATE_BIT1  = 3'b010;
    localparam STATE_BIT2  = 3'b011;
    localparam STATE_BIT3  = 3'b100;
    localparam STATE_DONE  = 3'b101;

    reg [2:0] state;

    reg [31:0] mrw;
    reg [31:0] msize;
    reg [31:0] maddr;
    reg [31:0] mdatai;

    always @(posedge clk_i, negedge nrst_i) begin
        if (!nrst_i) begin
            datao <= 0;

            mrw    <= 0;
            msize  <= 0;
            maddr  <= 0;
            mdatai <= 0;

            state <= STATE_READY;
        end
        else if (clk_i) begin
            case (state)
                STATE_READY: begin
                    if (req) begin
                        datao <= 0;

                        mrw    <= rw;
                        msize  <= size;
                        maddr  <= addr - ADDRESS;
                        mdatai <= datai;

                        state <= STATE_BIT0;
                    end
                end

                STATE_BIT0: begin
                    if (mrw) mem[maddr + 0] <= mdatai[7:0];
                    else datao[7:0]       <= mem[maddr + 0];

                    if (size == 0) state <= STATE_DONE;
                    else state <= STATE_BIT1;
                end

                STATE_BIT1: begin
                    if (mrw) mem[maddr + 1] <= mdatai[15:8];
                    else datao[15:8]      <= mem[maddr + 1];

                    if (size == 1) state <= STATE_DONE;
                    else state <= STATE_BIT2;
                end

                STATE_BIT2: begin
                    if (mrw) mem[maddr + 2] <= mdatai[23:16];
                    else datao[23:16]     <= mem[maddr + 2];

                    state <= STATE_BIT3;
                end

                STATE_BIT3: begin
                    if (mrw) mem[maddr + 3] <= mdatai[31:24];
                    else datao[31:24]     <= mem[maddr + 3];

                    state <= STATE_DONE;
                end

                STATE_DONE: begin
                    state <= STATE_READY;
                end
            endcase
        end
    end

    assign ack = state != STATE_READY;

endmodule
