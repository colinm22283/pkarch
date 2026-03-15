`timescale 1ns/100ps

`include "bus.svh"

module bus_master_m(
    input wire clk_i,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o
);

    initial begin
        mport_o = 0;
    end

    task WRITE_BYTE;
        input bus_addr_t addr;
        input bus_data_t data;
    begin
        wait(!clk_i);

        mport_o.rw   = BUS_RW_WRITE;
        mport_o.size = BUS_SIZE_BYTE;
        mport_o.req  = 1;
        mport_o.addr = addr;
        mport_o.data = data;

        wait(mport_i.ack);
        wait(!mport_i.ack);
        #1;

        mport_o.req = 0;

        wait(clk_i);
        #1;
    end
    endtask

    task READ_BYTE;
        input  bus_addr_t addr;
        output bus_data_t data;
    begin
        wait(!clk_i);

        mport_o.rw   = BUS_RW_READ;
        mport_o.size = BUS_SIZE_BYTE;
        mport_o.req  = 1;
        mport_o.addr = addr;

        wait(mport_i.ack);
        wait(!mport_i.ack);
        #1;

        data = mport_i.data;
        mport_o.req = 0;

        wait(clk_i);
        #1;
    end
    endtask
    
    task WRITE_WORD;
        input bus_addr_t addr;
        input bus_data_t data;
    begin
        wait(!clk_i);

        mport_o.rw   = BUS_RW_WRITE;
        mport_o.size = BUS_SIZE_WORD;
        mport_o.req  = 1;
        mport_o.addr = addr;
        mport_o.data = data;

        wait(mport_i.ack);
        wait(!mport_i.ack);
        #1;

        mport_o.req = 0;

        wait(clk_i);
        #1;
    end
    endtask

    task READ_WORD;
        input  bus_addr_t addr;
        output bus_data_t data;
    begin
        wait(!clk_i);

        mport_o.rw   = BUS_RW_READ;
        mport_o.size = BUS_SIZE_WORD;
        mport_o.req  = 1;
        mport_o.addr = addr;

        wait(mport_i.ack);
        wait(!mport_i.ack);
        #1;

        data = mport_i.data;
        mport_o.req = 0;

        wait(clk_i);
        #1;
    end
    endtask

endmodule
