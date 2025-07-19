`include "defs.v"

module tb_bus();

    logger_m logger();

    reg clk;
    reg nrst;

    initial forever begin
        clk <= 1;
        #10;
        clk <= 0;
        #10;
    end

    reg  [`BUS_PORT] portai;
    reg  [`BUS_PORT] portbi;
    wire [`BUS_PORT] portci;
    wire [`BUS_PORT] portdi;
    wire [`BUS_PORT] portao;
    wire [`BUS_PORT] portbo;
    wire [`BUS_PORT] portco;
    wire [`BUS_PORT] portdo;

    busint_m #(4) interconnect(
        .clk_i(clk),
        .nrst_i(nrst),

        .ports_i({ portai, portbi, portci, portdi }),
        .ports_o({ portao, portbo, portco, portdo })
    );

    ram_m #(0, 32) ram(
        .clk_i(clk),
        .nrst_i(nrst),

        .port_i(portco),
        .port_o(portci)
    );

    dma_m #(32) dma(
        .clk_i(clk),
        .nrst_i(nrst),

        .port_i(portdo),
        .port_o(portdi)
    );

    initial begin
        portai = 0;
        portbi = 0;

        nrst = 0;
        #30;
        nrst = 1;
        #30;

        #1000;
        $finish;
    end

    initial begin : MAIN_1
        reg [31:0] read_data;

        #100;

        PORTA_READ(4, read_data);
        PORTA_READ(5, read_data);
        PORTA_READ(6, read_data);
    end

    task PORTA_READ;
        input  [31:0] addr;
        output [31:0] data;
    begin
        portai[`BUS_ADDR] = addr;
        portai[`BUS_RW]   = 0;
        portai[`BUS_SIZE] = 0;
        portai[`BUS_REQ]  = 1;

        wait(portao[`BUS_ACK]);
        wait(!portao[`BUS_ACK]);
        $display("A READ %0d: %0d", addr, portao[`BUS_DATA]);
        portai[`BUS_REQ] = 0;
    end
    endtask

    task PORTB_READ;
        input  [31:0] addr;
        output [31:0] data;
    begin
        portbi[`BUS_ADDR] = addr;
        portbi[`BUS_RW]   = 0;
        portbi[`BUS_SIZE] = 0;
        portbi[`BUS_REQ]  = 1;

        wait(portbo[`BUS_ACK]);
        wait(!portbo[`BUS_ACK]);
        $display("B READ %0d: %0d", addr, portbo[`BUS_DATA]);
        portbi[`BUS_REQ] = 0;
    end
    endtask

endmodule
