`timescale 1ns/100ps

`include "config.svh"
`include "bus.svh"
`include "lsq.svh"
`include "memory_port.svh"

module lsq_m(
    input wire clk_i,
    input wire nrst_i,

    input  bus_miport_t [MEMORY_PORTS - 1:0] mports_i,
    output bus_moport_t [MEMORY_PORTS - 1:0] mports_o,

    input  lsq_dispatch_i_t dispatch_i,
    output lsq_dispatch_o_t dispatch_o,

    bit lsq_commit_i,
    bit lsq_ack_o
);

    localparam LSQ_INDEX_WIDTH = $clog2(LSQ_SIZE);
    localparam LSQ_SIZE_WIDTH  = $clog2(LSQ_SIZE + 1);

    logic [LSQ_SIZE_WIDTH - 1:0] size;
    lsq_entry_t [LSQ_SIZE - 1:0] entries;

    enum logic [1:0] {
        STATE_IDLE,
        STATE_RUNNING,
        STATE_COMMITTING
    } [MEMORY_PORTS - 1:0] states;

    memory_port_i_t [MEMORY_PORTS - 1:0] memory_portsi;
    memory_port_o_t [MEMORY_PORTS - 1:0] memory_portso;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            size = 0;

            for (int i = 0; i < MEMORY_PORTS; i++) states[i] = STATE_IDLE;

            mports_o = 0;
        end
        else begin
            lsq_ack_o = 0;

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
                    STATE_RUNNING: begin
                        if (memory_portso[i].ack) begin
                            states[i] = STATE_COMMITTING;
                        end
                    end

                    STATE_COMMITTING: begin
                        states[i] = STATE_IDLE;
                        
                        lsq_ack_o = 1;
                    end
                    
                    default: ;
                endcase
            end

            begin
                logic cont;
                cont = 1;
                for (int i = 0; i < MEMORY_PORTS; i++) begin
                    if (cont && i < size && states[i] == STATE_IDLE) begin
                        if (entries[i].rw == BUS_RW_WRITE) begin
                            if (lsq_commit_i) begin
                                states[i] = STATE_RUNNING;
                            end

                            cont = 0;
                        end
                        else begin
                            states[i] = STATE_RUNNING;
                        end
                    end
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < MEMORY_PORTS; i++) begin
            memory_portsi[i].req = states[i] == STATE_RUNNING;
        end
    end

    generate for (genvar i = 0; i < MEMORY_PORTS; i++) begin
        memory_port_m memory_port(
            .clk_i(clk_i),
            .nrst_i(nrst_i),

            .stream_port_i(memory_portsi[i]),
            .stream_port_o(memory_portso[i]),

            .mport_i(mports_i[i]),
            .mport_o(mports_o[i])
        );
    end endgenerate

endmodule

