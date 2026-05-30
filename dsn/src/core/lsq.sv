`include "config.svh"
`include "core/lsq.svh"
`include "bus/bus.svh"
`include "test/logger.svh"

module lsq_m(
    input wire clk_i,
    input wire nrst_i,

    input  bus_miport_t [MEMORY_PORTS - 1:0] mports_i,
    output bus_moport_t [MEMORY_PORTS - 1:0] mports_o,

    input  lsq_dispatch_i_t dispatch_i,
    output lsq_dispatch_o_t dispatch_o,

    input  commit_o_t [MEMORY_PORTS - 1:0] commit_i,
    output commit_i_t [MEMORY_PORTS - 1:0] commit_o,

    input  commit_o_t write_commit_i,
    output commit_i_t write_commit_o,

    input  wire rob_write_valid_i,
    output wire rob_write_ready_o
);

    `DL_DEFINE(log, "lsq_m", `DL_YELLOW, `DL_ENABLE_LSQ);

    localparam LSQ_SIZE_WIDTH = $clog2(LSQ_SIZE + 1);

    logic [LSQ_SIZE_WIDTH - 1:0] size;
    lsq_entry_t [LSQ_SIZE - 1:0] entries;

    logic mem_active;
    enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_ACK,
        STATE_DONE
    } [MEMORY_PORTS - 1:0] states;
    lsq_entry_t [MEMORY_PORTS - 1:0] active_entries;

    word_t [MEMORY_PORTS - 1:0] commit_data;

    logic accept_dispatch;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            size = 0;

            for (int i = 0; i < MEMORY_PORTS; i++) begin
                states[i] = STATE_IDLE;
            end
        end
        else begin
            if (!mem_active) begin
                logic cont;
                logic [$clog2(MEMORY_PORTS + 1) - 1:0] activate_count;

                cont = 1;
                activate_count = 0;

                for (int i = 0; i < MEMORY_PORTS; i++) begin
                    if (cont && i < size) begin
                        if (entries[0].rw == BUS_RW_READ) begin
                            active_entries[i] = entries[0];
                            states[i] = STATE_REQ;

                            activate_count = activate_count + 1;
                        end
                        else begin
                            if (rob_write_valid_i) begin
                                active_entries[i] = entries[0];
                                states[i] = STATE_REQ;

                                activate_count = activate_count + 1;
                            end
                            else begin
                                cont = 0;
                            end
                        end
                    end
                end

                for (int j = 0; j < LSQ_SIZE; j++) begin
                    if (j < LSQ_SIZE - 32'(activate_count)) begin
                        entries[j] = entries[j + 32'(activate_count)];
                    end
                end
                size = size - LSQ_SIZE_WIDTH'(activate_count);

                if (activate_count != 0) begin
                    `DL(log, ("Activating %0d memory transactions", activate_count));
                end
            end



            for (int i = 0; i < MEMORY_PORTS; i++) begin
                case (states[i])
                    STATE_IDLE: ;

                    STATE_REQ: begin
                        if (mports_i[i].ack) begin
                            states[i] = STATE_ACK;

                            `DL(log, ("write %h to %h", mports_o[i].data, mports_o[i].addr));
                        end
                    end

                    STATE_ACK: begin
                        if (!mports_i[i].ack) begin
                            states[i] = STATE_DONE;

                            commit_data[i] = mports_i[i].data;
                        end
                    end

                    STATE_DONE: begin
                        if (commit_i[i].ready) begin
                            states[i] = STATE_IDLE;
                        end
                    end
                endcase
            end

            if (dispatch_i.valid && accept_dispatch) begin
                entries[size].rob_id = dispatch_i.rob_id;
                entries[size].size = dispatch_i.size;
                entries[size].rw = dispatch_i.rw;
                entries[size].addr = dispatch_i.addr;
                entries[size].data = dispatch_i.data;

                size = size + 1;
            end
        end
    end

    always_comb begin
        mem_active = 0;
        for (int i = 0; i < MEMORY_PORTS; i++) begin
            mem_active |= states[i] != STATE_IDLE;
        end

        rob_write_ready_o = 0;
        if (!mem_active) begin
            for (int i = 0; i < MEMORY_PORTS; i++) begin
                if (i < size) begin
                    if (entries[i].rw == BUS_RW_WRITE) rob_write_ready_o = 1;
                end
            end
        end

        for (int i = 0; i < MEMORY_PORTS; i++) begin
            mports_o[i].seqmst = 0;

            mports_o[i].size = active_entries[i].size;
            mports_o[i].rw = active_entries[i].rw;
            mports_o[i].addr = active_entries[i].addr;
            mports_o[i].data = active_entries[i].data.write.value;

            commit_o[i].rob_id = active_entries[i].rob_id;
            commit_o[i].jmp = 0;
            commit_o[i].jmp_target = 0;
            commit_o[i].isa_addr = active_entries[i].data.read.isa_addr;
            commit_o[i].rd = active_entries[i].data.read.rd;
            commit_o[i].prev_rd = active_entries[i].data.read.prev_rd;
            commit_o[i].value = commit_data[i];

            case (states[i])
                STATE_IDLE: begin
                    mports_o[i].req = 0;
                    commit_o[i].valid = 0;
                end

                STATE_REQ: begin
                    mports_o[i].req = 1;
                    commit_o[i].valid = 0;
                end

                STATE_ACK: begin
                    mports_o[i].req = 1;
                    commit_o[i].valid = 0;
                end

                STATE_DONE: begin
                    mports_o[i].req = 0;
                    if (active_entries[i].rw == BUS_RW_READ) commit_o[i].valid = 1;
                end
            endcase
        end

        if (dispatch_i.rw == BUS_RW_WRITE) begin
            accept_dispatch = 32'(size) < LSQ_SIZE && write_commit_i.ready;
        end
        else begin
            accept_dispatch = 32'(size) < LSQ_SIZE;
        end

        write_commit_o = 0;
        write_commit_o.valid = dispatch_i.rw == BUS_RW_WRITE && dispatch_i.valid && accept_dispatch;
        write_commit_o.rob_id = dispatch_i.rob_id;
        write_commit_o.mem = 1;

        dispatch_o.ready = accept_dispatch;
    end

endmodule

