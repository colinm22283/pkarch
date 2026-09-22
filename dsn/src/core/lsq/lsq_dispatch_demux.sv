`timescale 1ns/100ps

`include "core/lsq.svh"

module lsq_dispatch_demux_m(
    input  lsq_dispatch_i_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_i,
    output lsq_dispatch_o_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_o,

    input  logic    read_ready_i,
    output logic    read_valid_o,
    output rob_id_t read_rob_id_o,

    input  logic    write_ready_i,
    output logic    write_valid_o,
    output rob_id_t write_rob_id_o
);

    always_comb begin
        read_valid_o   = '0;
        read_rob_id_o  = '0;

        write_valid_o  = '0;
        write_rob_id_o = '0;

        lsq_dispatch_o = '0;

        for (int i = 0; i < LSQ_DISPATCH_WIDTH; i++) begin
            if (lsq_dispatch_i[i].valid) begin
                case (lsq_dispatch_i[i].rw)
                    BUS_RW_READ: begin
                        if (read_ready_i) begin
                            lsq_dispatch_o[i].ready = 'b1;

                            read_valid_o  = 'b1;
                            read_rob_id_o = lsq_dispatch_i[i].rob_id;
                        end
                    end

                    BUS_RW_WRITE: begin
                        if (write_ready_i) begin
                            lsq_dispatch_o[i].ready = 'b1;

                            write_valid_o  = 'b1;
                            write_rob_id_o = lsq_dispatch_i[i].rob_id;
                        end
                    end
                endcase
            end
        end
    end

endmodule
    
