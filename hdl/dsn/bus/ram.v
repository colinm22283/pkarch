`include "defs.vh"

module ram_m #(
    parameter ADDRESS = 0,
    parameter SIZE = 1
) (
    input wire clk_i,
    input wire nrst_i,

    input  wire [`BUS_SIPORT] sport_i,
    output reg  [`BUS_SOPORT] sport_o
);

    wire [`WORD_WIDTH - 1:0] sport_datai;
    assign sport_datai = sport_i[`BUS_SI_DATA];

    reg  [`WORD_WIDTH - 1:0] sport_datao;

    reg [7:0] mem [SIZE - 1:0];
    initial begin : MEM_INIT
        integer i;

        for (i = 0; i < SIZE; i = i + 1) mem[i] <= i;
    end

    localparam STATE_READY   = 3'b000;
    localparam STATE_RUNNING = 3'b001;
    localparam STATE_WAIT    = 3'b010;
    localparam STATE_DONE    = 3'b011;

    reg [2:0] state;

    reg [2:0] byte_count;
    reg [2:0] current_byte;

    always @(posedge clk_i, negedge nrst_i) begin
        if (!nrst_i) begin
            state        <= STATE_READY;

            sport_datao  <= 0;

            byte_count   <= 0;
            current_byte <= 0;
        end
        else if (clk_i) begin
            case (state)
                STATE_READY: begin
                    if (
                        sport_i[`BUS_SI_REQ] &&
                        sport_i[`BUS_SI_ADDR] - ADDRESS < SIZE
                    ) begin
                        state <= STATE_RUNNING;
                        
                        case (sport_i[`BUS_SI_SIZE])
                            `BUS_SIZE_BYTE: byte_count <= 1 - 1;
                            `BUS_SIZE_WORD: byte_count <= 4 - 1;
                        endcase

                        current_byte <= 0;
                    end
                end

                STATE_RUNNING: begin
                    if (sport_i[`BUS_SI_RW] == `BUS_WRITE) begin
                        if (current_byte == byte_count) begin
                            if (byte_count == 0) state <= STATE_WAIT;
                            else state <= STATE_DONE;
                        end

                        mem[sport_i[`BUS_SI_ADDR] + current_byte]
                            <= sport_datai[current_byte * 8+:8];
                    end
                    else begin
                        if (current_byte == byte_count) begin
                            if (byte_count == 0) state <= STATE_WAIT;
                            else state <= STATE_DONE;
                        end

                        sport_datao[current_byte * 8+:8]
                            <= mem[sport_i[`BUS_SI_ADDR] + current_byte];
                    end

                    current_byte <= current_byte + 1;
                end

                STATE_WAIT: begin
                    state <= STATE_DONE;
                end

                STATE_DONE: begin
                    if (!sport_i[`BUS_SI_REQ]) begin
                        state <= STATE_READY;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        sport_o <= 0;

        sport_o[`BUS_SO_DATA] <= sport_datao;

        case (state)
            default: begin
                sport_o[`BUS_SO_ACK] <= 0;
            end

            STATE_RUNNING, STATE_WAIT: begin
                sport_o[`BUS_SO_ACK] <= 1;
            end
        endcase
    end

endmodule
