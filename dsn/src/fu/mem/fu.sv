`include "fu.svh"
`include "commit.svh"
`include "prf.svh"

module mem_fu_m(
    input wire clk_i,
    input wire nrst_i,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o,

    input  fu_dispatch_i_t dispatch_i,
    output fu_dispatch_o_t dispatch_o,

    input  prf_rport_o_t rport_i,
    output prf_rport_i_t rport_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    word_t write_data;
    word_t read_data;
    word_t addr;
    sword_t offset;

    bus_rw_t rw;
    bus_size_t size;
    logic read_ports_valid;
    logic out_ready;

    enum logic [2:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_WAIT_READ,
        STATE_WAIT_WRITE
    } state;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state   <= STATE_IDLE;
            
            mport_o <= 0;
        end
        else begin
            case (state)
                STATE_IDLE: begin
                    if (dispatch_i.valid && read_ports_valid) begin
                        if (mport_i.ack) state <= STATE_REQ;

                        mport_o.rw   <= rw;
                        mport_o.size <= size;
                        mport_o.req  <= 1;
                        mport_o.addr <= addr + offset;
                        mport_o.data <= write_data;
                    end
                end

                STATE_REQ: begin
                    if (!mport_i.ack) begin
                        if (rw == BUS_RW_READ) begin
                            state <= STATE_WAIT_READ;

                            read_data <= mport_i.data;
                        end
                    end
                end

                STATE_WAIT_READ: begin
                    if (commit_i.ready) begin
                    end
                end

                default: ;
            endcase
        end
    end

    always_comb begin
        case (dispatch_i.dec_inst.funct)
            FUNCT_LB: begin
                rw = BUS_RW_READ;
                size = BUS_SIZE_BYTE;
            end

            default: begin
                rw = BUS_RW_READ;
                size = BUS_SIZE_BYTE;
            end
        endcase

        rport_o.addr = dispatch_i.rs1;

        addr = rport_i.data;
        offset = dispatch_i.dec_inst.imm;

        read_ports_valid = rport_i.valid;

        out_ready = 
            (
                state == STATE_WAIT_READ ||
                state == STATE_WAIT_WRITE
            ) &&
            commit_i.ready;

        dispatch_o.ready = out_ready;

        commit_o.valid    = out_ready;
        commit_o.rob_id   = dispatch_i.rob_id;
        commit_o.isa_addr = dispatch_i.isa_addr;
        commit_o.rd       = dispatch_i.rd;
        commit_o.value    = read_data;
    end

endmodule
