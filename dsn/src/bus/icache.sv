`include "defs.svh"
`include "bus/bus.svh"
`include "bus/icache.svh"
`include "test/logger.svh"

`include "config.svh"

module icache_m #(
    parameter INDEX_BITS = 10,
    parameter OFFSET_BITS = 5,
    parameter WAYS = 2,
    parameter TIMEOUT = 50
) (
    input wire clk_i,
    input wire nrst_i,

    input  icache_i_t icache_i,
    output icache_o_t icache_o,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o
);

    `DL_DEFINE(log, "icache_m", `DL_GREEN, `DL_ENABLE_ICACHE);

    logic nrst;
    reset_buf_m reset_buf(
        .clk_i(clk_i),
        .nrst_i(nrst_i),
        .nrst_o(nrst)
    );

    localparam BLOCK_SIZE = (2 ** OFFSET_BITS) / 4;
    localparam SIZE = BLOCK_SIZE * (2 ** INDEX_BITS);
    localparam SET_COUNT = SIZE / BLOCK_SIZE;

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
        inst_t [BLOCK_SIZE - 1:0] [DISPATCH_WIDTH - 1:0] mem;
    } way_t;

    typedef way_t set_t [WAYS - 1:0];

    set_t sets_q [SET_COUNT - 1:0];
    set_t sets_d [SET_COUNT - 1:0];

    enum logic [1:0] {
        STATE_READY,
        STATE_REQ,
        STATE_ACK,
        STATE_DONE
    } state_q, state_d;

    logic [$clog2(DISPATCH_WIDTH) - 1:0] fetch_inst_q, fetch_inst_d;
    offset_t                             fetch_offset_d, fetch_offset_d;
    index_t                              fetch_index_q, fetch_index_d;
    bus_addr_t                           fetch_addr_q, fetch_addr_d;

    addr_t test_addr;
    logic test_found;
    way_index_t test_way;

    always_ff @(posedge clk_i) begin
        if (!nrst) begin
            for (int i = 0; i < SET_COUNT; i++) begin
                for (int j = 0; j < WAYS; j++) begin
                    sets_q[i][j].valid = 1'b0;
                end
            end

            state_q <= STATE_READY;
        end
        else begin
            sets_q <= sets_d;

            state_q <= state_d;

            fetch_inst_q   <= fetch_inst_d;
            fetch_offset_q <= fetch_offset_d;
            fetch_index_q  <= fetch_index_d;
            fetch_addr_q   <= fetch_addr_d;
        end
    end

    always_comb begin
        sets_d = sets_q;

        state_d = state_q;

        fetch_inst_d   = fetch_inst_d;
        fetch_offset_d = fetch_offset_q;
        fetch_index_d  = fetch_index_q;
        fetch_addr_d   = fetch_addr_q;
    end

endmodule

