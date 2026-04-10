`include "bus.svh"
`include "defs.svh"
`include "icache.svh"
`include "logger.svh"

module icache_m #(
    parameter INDEX_BITS = 10,
    parameter OFFSET_BITS = 5,
    parameter WAYS = 2
) (
    input wire clk_i,
    input wire nrst_i,

    input  icache_i_t icache_i,
    output icache_o_t icache_o,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o
);

    `DL_DEFINE(log, "icache_m", `DL_GREEN, `DL_ENABLE_ICACHE);

    localparam BLOCK_SIZE = 2 ** OFFSET_BITS / 4;
    localparam SIZE = BLOCK_SIZE * (2 ** INDEX_BITS);
    localparam SET_COUNT = SIZE / WAYS / BLOCK_SIZE;

    typedef logic [OFFSET_BITS - 1:0] offset_t;
    typedef logic [INDEX_BITS - 1:0] index_t;
    typedef logic [BUS_ADDR_WIDTH - INDEX_BITS - OFFSET_BITS - 1:0] tag_t;

    typedef logic [$clog2(WAYS) - 1:0] way_index_t;

    typedef union packed {
        bus_addr_t addr;
        struct packed {
            tag_t tag;
            index_t index;
            offset_t offset;
        } parts;
    } addr_t;

    typedef struct packed {
        bit valid;
        tag_t tag;
        word_t [BLOCK_SIZE - 1:0] mem;
    } way_t;

    typedef way_t [WAYS - 1:0] set_t;

    set_t [SET_COUNT - 1:0] sets;

    enum {
        STATE_READY,
        STATE_ACCESS,
        STATE_FETCH
    } state;

    enum {
        FSTATE_REQ,
        FSTATE_ACK,
        FSTATE_DONE
    } fstate;

    offset_t fetch_index;
    bus_addr_t fetch_addr;

    addr_t test_addr;
    logic test_found;
    way_index_t test_way;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            for (int i = 0; i < SET_COUNT; i++) begin
                for (int j = 0; j < WAYS; j++) begin
                    sets[i][j].valid = 0;
                end
            end

            state <= STATE_READY;
        end
        else begin
            case (state)
                STATE_READY: begin
                    if (icache_i.req) begin
                        if (test_found) state <= STATE_ACCESS;
                        else begin
                            state  = STATE_FETCH;
                            fstate = FSTATE_REQ;

                            fetch_index = 0;
                            fetch_addr  = icache_i.addr & ~(BUS_ADDR_WIDTH'({OFFSET_BITS{1'b1}}));

                            for (int i = WAYS - 1; i > 0; i--) begin
                                sets[test_addr.parts.index][i] = sets[test_addr.parts.index][i - 1];
                            end

                            sets[test_addr.parts.index][0].valid = 1;
                            sets[test_addr.parts.index][0].tag = test_addr.parts.tag;
                        end
                    end
                end

                STATE_ACCESS: begin
                    state <= STATE_READY;
                end

                STATE_FETCH: begin
                    case (fstate)
                        FSTATE_REQ: begin
                            if (mport_i.ack) begin
                                fstate = FSTATE_ACK;
                            end
                        end

                        FSTATE_ACK: begin
                            if (!mport_i.ack) begin
                                if (fetch_index == BLOCK_SIZE - 1) state = STATE_READY;
                                else fstate = FSTATE_DONE;

                                sets[test_addr.parts.index][0].mem[fetch_index] = mport_i.data;

                                `DL(log, ("Load 0x%x into 0x%x, 0x%x", mport_i.data, test_addr.parts.index, fetch_index));
                            end
                        end

                        FSTATE_DONE: begin
                            fstate = FSTATE_REQ;

                            fetch_addr = fetch_addr + 4;
                            fetch_index = fetch_index + 1;
                        end
                    endcase
                end
            endcase
        end
    end

    always_comb begin
        case (state)
            STATE_ACCESS: begin
                icache_o.ack  = 1;
                icache_o.data = sets[test_addr.parts.index][test_way].mem[test_addr.parts.offset / 4];
            end

            default: begin
                icache_o.ack  = 0;
                icache_o.data = 0;
            end
        endcase

        mport_o      = 0;
        mport_o.rw   = BUS_RW_READ;
        mport_o.size = BUS_SIZE_WORD;
        mport_o.addr = fetch_addr;

        if (state == STATE_FETCH) begin
            case (fstate)
                FSTATE_REQ: begin
                    mport_o.req  = 1;
                end

                FSTATE_ACK: begin
                    mport_o.req  = 1;
                end
            endcase
        end
    end

    always_comb begin
        test_addr.addr = icache_i.addr;

        test_found = 0;
        test_way = 0;

        for (int i = 0; i < WAYS; i++) begin
            if (
                sets[test_addr.parts.index][i].valid &&
                sets[test_addr.parts.index][i].tag == test_addr.parts.tag
            ) begin
                test_found = 1;
                test_way = $bits(way_index_t)'(i);
            end
        end
    end

endmodule

