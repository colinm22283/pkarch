`include "fu/fu.svh"
`include "core/commit.svh"
`include "core/prf.svh"
`include "core/lsq.svh"
`include "test/logger.svh"

module mem_fu_m(
    input wire clk_i,
    input wire nrst_i,

    input  fu_dispatch_i_t dispatch_i,
    output fu_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [1:0] rport_i,
    output prf_rport_i_t [1:0] rport_o,

    input  lsq_dispatch_o_t lsq_dispatch_i,
    output lsq_dispatch_i_t lsq_dispatch_o
);

    `DL_DEFINE(log, "mem_fu_m", `DL_YELLOW, `DL_ENABLE_MEM_FU);

    word_t addr;
    sword_t offset;

    bus_rw_t rw;
    bus_size_t size;
    logic read_ports_valid;

    always_comb begin
        case (dispatch_i.dec_inst.opcode)
            OPCODE_LOAD: begin
                rw = BUS_RW_READ;

                case (dispatch_i.dec_inst.funct)
                    FUNCT_LB: begin
                        size = BUS_SIZE_BYTE;
                    end

                    FUNCT_LH: begin
                        size = BUS_SIZE_HALF;
                    end

                    FUNCT_LW: begin
                        size = BUS_SIZE_WORD;
                    end

                    default: begin
                        size = BUS_SIZE_BYTE;
                    end
                endcase
            end

            OPCODE_STORE: begin
                rw = BUS_RW_WRITE;

                case (dispatch_i.dec_inst.funct)
                    FUNCT_SB: begin
                        size = BUS_SIZE_BYTE;
                    end

                    FUNCT_SH: begin
                        size = BUS_SIZE_HALF;
                    end

                    FUNCT_SW: begin
                        size = BUS_SIZE_WORD;
                    end

                    default: begin
                        size = BUS_SIZE_BYTE;
                    end
                endcase
            end

            default: begin
                rw = BUS_RW_READ;
                size = BUS_SIZE_BYTE;
            end
        endcase

        rport_o[0].addr = dispatch_i.rs1;
        rport_o[1].addr = dispatch_i.rs2;

        addr = rport_i[0].data;
        offset = dispatch_i.dec_inst.imm;

        if (rw == BUS_RW_READ) begin
            read_ports_valid = rport_i[0].valid;
        end
        else begin
            read_ports_valid = rport_i[0].valid && rport_i[1].valid;
        end

        // write_data = rport_i[1].data;

        dispatch_o.ready = lsq_dispatch_i.ready && read_ports_valid;

        lsq_dispatch_o.valid  = dispatch_i.valid && read_ports_valid;
        lsq_dispatch_o.rob_id = dispatch_i.rob_id;
        lsq_dispatch_o.size   = size;
        lsq_dispatch_o.rw     = rw;
        lsq_dispatch_o.addr   = addr + offset;

        if (rw == BUS_RW_READ) begin
            lsq_dispatch_o.data.read.isa_addr = dispatch_i.isa_addr;
            lsq_dispatch_o.data.read.rd = dispatch_i.rd;
            lsq_dispatch_o.data.read.prev_rd = dispatch_i.prev_rd;
        end
        else begin
            lsq_dispatch_o.data.write.value = rport_i[1].data;
        end
    end

endmodule
