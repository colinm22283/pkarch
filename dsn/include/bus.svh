`ifndef BUS_SVH
`define BUS_SVH

`include "defs.svh"

parameter BUS_ADDR_WIDTH = WORD_WIDTH;
parameter BUS_DATA_WIDTH = WORD_WIDTH;

typedef logic [BUS_ADDR_WIDTH - 1:0] bus_addr_t;
typedef logic [BUS_DATA_WIDTH - 1:0] bus_data_t;

typedef enum logic [0:0] {
    BUS_RW_READ,
    BUS_RW_WRITE
} bus_rw_t;

typedef enum logic [1:0] {
    BUS_SIZE_BYTE,
    BUS_SIZE_WORD,
    BUS_SIZE_STREAM
} bus_size_t;

typedef struct packed {
    bit seqslv;
    bit ack;
    bus_data_t data;
} bus_miport_t;

typedef struct packed {
    bus_rw_t rw;
    bus_size_t size;
    bit seqmst;
    bit req;
    bus_addr_t addr;
    bus_data_t data;
} bus_moport_t;

typedef bus_miport_t bus_soport_t;
typedef bus_moport_t bus_siport_t;

`endif

