`timescale 1ns/100ps

`include "config.svh"
`include "bus.svh"
`include "lsq.svh"

module lsq_m(
    input wire clk_i,
    input wire nrst_i,

    bus_miport_t [MEMORY_PORTS - 1:0] mports_i,
    bus_moport_t [MEMORY_PORTS - 1:0] mports_o,

    lsq_dispatch_i_t dispatch_i,
    lsq_dispatch_o_t dispatch_o,

    commit_o_t commit_i,
    commit_i_t commit_o,

    bit mem_commit_run_i,
    bit mem_commit_complete_o
);

    localparam LSQ_INDEX_WIDTH = $clog2(LSQ_SIZE);
    localparam LSQ_SIZE_WIDTH  = $clog2(LSQ_SIZE + 1);

    logic [LSQ_SIZE_WIDTH - 1:0] size;
    lsq_entry_t [LSQ_SIZE - 1:0] entries;

    enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ
    } [MEMORY_PORTS - 1:0] states;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            size = 0;

            for (int i = 0; i < MEMORY_PORTS; i++) states[i] = STATE_IDLE;

            mports_o = 0;
        end
        else begin
            if (dispatch_i.valid && size < LSQ_SIZE) begin
                entries[size].rw     = dispatch_i.rw;
                entries[size].size   = dispatch_i.size;
                entries[size].rob_id = dispatch_i.rob_id;
                entries[size].addr   = dispatch_i.addr;

                if (dispatch_i.rw == BUS_RW_READ) begin
                    entries[size].data.read.isa_addr = dispatch_i.data.read.isa_addr;
                    entries[size].data.read.rd       = dispatch_i.data.read.rd;
                    entries[size].data.read.prev_rd  = dispatch_i.data.read.prev_rd;
                end
                else begin
                    entries[size].data.write.value = dispatch_i.data.write.value;
                end

                size = size + 1;
            end

            for (int i = 0; i < MEMORY_PORTS; i++) begin
                case (states[i])
                    STATE_IDLE: ;

                    STATE_REQ: begin
                        mports_o[i].req = 1;
                    end
                endcase
            end

            logic cont;
            cont = 1;
            for (int i = 0; i < MEMORY_PORTS; i++) begin
                if (cont && i < size && states[i] == STATE_IDLE) begin
                    states[i] = STATE_REQ;
                    if (entries[i].rw == BUS_RW_WRITE) begin
                        cont = 0;
                    end
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < MEMORY_PORTS; i++) begin
            mports_o[i].rw     = entries[i].rw;
            mports_o[i].size   = entries[i].size;
            mports_o[i].addr   = entries[i].addr;
            mports_o[i].seqmst = 0;
        end
    end

endmodule

