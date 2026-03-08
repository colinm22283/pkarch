module virtual_master_m(
    input wire clk_i,
    input wire nrst_i,

    input  wire [`BUS_MIPORT] mport_i,
    output reg  [`BUS_MOPORT] mport_o
);

    initial begin
        mport_o = 0;
    end

    task WRITE_BYTE;
        input [`BUS_ADDR_PORT] addr;
        input [7:0] data;
    begin
        wait(!clk_i);

        mport_o[`BUS_MO_ADDR] = addr;
        mport_o[`BUS_MO_DATA] = data;
        mport_o[`BUS_MO_SIZE] = `BUS_SIZE_BYTE;
        mport_o[`BUS_MO_RW]   = `BUS_WRITE;
        mport_o[`BUS_MO_REQ]  = 1;

        wait(mport_i[`BUS_MI_ACK]);
        wait(!mport_i[`BUS_MI_ACK]);

        mport_o[`BUS_MO_REQ]  = 0;

        wait(!clk_i);
        wait(clk_i);
    end
    endtask

    task WRITE_WORD;
        input [`BUS_ADDR_PORT] addr;
        input [31:0] data;
    begin
        wait(!clk_i);

        mport_o[`BUS_MO_ADDR] = addr;
        mport_o[`BUS_MO_DATA] = data;
        mport_o[`BUS_MO_SIZE] = `BUS_SIZE_WORD;
        mport_o[`BUS_MO_RW]   = `BUS_WRITE;
        mport_o[`BUS_MO_REQ]  = 1;

        wait(mport_i[`BUS_MI_ACK]);
        wait(!mport_i[`BUS_MI_ACK]);

        mport_o[`BUS_MO_REQ]  = 0;

        wait(!clk_i);
        wait(clk_i);
    end
    endtask

    task WRITE_STREAM;
        input [`BUS_ADDR_PORT] addr;
        input [`BUS_ADDR_PORT] size;
        input [31:0] data;

        integer i;
    begin
        wait(!clk_i);

        mport_o[`BUS_MO_ADDR] = addr;
        mport_o[`BUS_MO_DATA] = data;
        mport_o[`BUS_MO_SIZE] = `BUS_SIZE_STREAM;
        mport_o[`BUS_MO_RW]   = `BUS_WRITE;
        mport_o[`BUS_MO_REQ]  = 1;

        wait(mport_i[`BUS_MI_ACK]);

        for (i = 0; i < size; i = i + 1) begin
            wait(mport_i[`BUS_MI_SEQSLV]);
            wait(!mport_i[`BUS_MI_SEQSLV]);
        end

        mport_o[`BUS_MO_SEQMST]  = 1;

        wait(!mport_i[`BUS_MI_ACK]);

        mport_o[`BUS_MO_REQ]  = 0;
        mport_o[`BUS_MO_SEQMST]  = 0;

        wait(!clk_i);
        wait(clk_i);
    end
    endtask

    task READ_BYTE;
        input [`BUS_ADDR_PORT] addr;
        output [7:0] data;
    begin
        wait(!clk_i);

        mport_o[`BUS_MO_ADDR] = addr;
        mport_o[`BUS_MO_SIZE] = `BUS_SIZE_BYTE;
        mport_o[`BUS_MO_RW]   = `BUS_READ;
        mport_o[`BUS_MO_REQ]  = 1;

        wait(mport_i[`BUS_MI_ACK]);
        wait(!mport_i[`BUS_MI_ACK]);

        data = mport_i[`BUS_MI_DATA];

        mport_o[`BUS_MO_REQ]  = 0;

        wait(!clk_i);
        wait(clk_i);
    end
    endtask

    task READ_WORD;
        input [`BUS_ADDR_PORT] addr;
        output [31:0] data;
    begin
        wait(!clk_i);

        mport_o[`BUS_MO_ADDR] = addr;
        mport_o[`BUS_MO_SIZE] = `BUS_SIZE_WORD;
        mport_o[`BUS_MO_RW]   = `BUS_READ;
        mport_o[`BUS_MO_REQ]  = 1;

        wait(mport_i[`BUS_MI_ACK]);
        wait(!mport_i[`BUS_MI_ACK]);

        data = mport_i[`BUS_MI_DATA];

        mport_o[`BUS_MO_REQ]  = 0;

        wait(!clk_i);
        wait(clk_i);
    end
    endtask

    task READ_STREAM;
        input [`BUS_ADDR_PORT] addr;
        input [`BUS_ADDR_PORT] size;

        integer i;
    begin
        wait(!clk_i);

        mport_o[`BUS_MO_ADDR] = addr;
        mport_o[`BUS_MO_SIZE] = `BUS_SIZE_STREAM;
        mport_o[`BUS_MO_RW]   = `BUS_READ;
        mport_o[`BUS_MO_REQ]  = 1;

        wait(mport_i[`BUS_MI_ACK]);

        for (i = 0; i < size - 1; i = i + 1) begin
            wait(mport_i[`BUS_MI_SEQSLV]);
            wait(!mport_i[`BUS_MI_SEQSLV]);

            $display("GOT DATA: 0x%h", mport_i[`BUS_MI_DATA]);
        end

        mport_o[`BUS_MO_SEQMST]  = 1;
        
        wait(!mport_i[`BUS_MI_ACK]);

        $display("GOT DATA: 0x%h", mport_i[`BUS_MI_DATA]);

        mport_o[`BUS_MO_REQ]  = 0;
        mport_o[`BUS_MO_SEQMST]  = 0;

        wait(!clk_i);
        wait(clk_i);
    end
    endtask

endmodule
