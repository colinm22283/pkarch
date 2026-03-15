`timescale 1ns/100ps

`include "bus.svh"

module ram_m #(
    parameter ADDRESS = 0,
    parameter SIZE = 16
) (
    input wire clk_i,
    input wire nrst_i,

    input  bus_siport_t sport_i,
    output bus_soport_t sport_o
);

    localparam ADDR_WIDTH = $clog2(SIZE);
    word_t [SIZE - 1:0] mem;

    enum logic [1:0] {
        STATE_READY,
        STATE_READ,
        STATE_WRITE,
        STATE_DONE
    } state;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state <= STATE_READY;

            sport_o <= 0;
        end
        else begin
            case (state)
                STATE_READY: begin
                    if (sport_i.req && sport_i.addr - ADDRESS < SIZE) begin
                        sport_o.ack <= 1;

                        if (sport_i.rw == BUS_RW_READ) begin
                            state <= STATE_READ;
                        end
                        else begin
                            state <= STATE_WRITE;
                        end
                    end
                end

                STATE_READ: begin
                    logic [ADDR_WIDTH - 1:0] addr;

                    addr = ADDR_WIDTH'((sport_i.addr - ADDRESS) / 4);

                    case (sport_i.size)
                        BUS_SIZE_BYTE: begin
                            logic [1:0] subaddr;

                            subaddr = 2'(sport_i.addr - ADDRESS) & 2'b11;

                            sport_o.data <= { 24'h000000, mem[addr][subaddr * 8 +: 8] };

                            state <= STATE_DONE;
                        end

                        BUS_SIZE_WORD: begin
                            sport_o.data <= mem[addr];

                            state <= STATE_DONE;
                        end

                        BUS_SIZE_STREAM: begin
                        end

                        default: ;
                    endcase
                end

                STATE_WRITE: begin
                    logic [ADDR_WIDTH - 1:0] addr;

                    addr = ADDR_WIDTH'((sport_i.addr - ADDRESS) / 4);

                    case (sport_i.size)
                        BUS_SIZE_BYTE: begin
                            logic [1:0] subaddr;

                            subaddr = 2'(sport_i.addr - ADDRESS) & 2'b11;

                            mem[addr][subaddr * 8 +: 8] <= sport_i.data[7:0];

                            state <= STATE_DONE;
                        end

                        BUS_SIZE_WORD: begin
                            mem[addr] <= sport_i.data;

                            state <= STATE_DONE;
                        end

                        BUS_SIZE_STREAM: begin
                        end

                        default: ;
                    endcase
                end

                STATE_DONE: begin
                    sport_o.ack  <= 0;

                    if (!sport_i.req) begin
                        state <= STATE_READY;
                    end
                end
            endcase
        end
    end

endmodule
