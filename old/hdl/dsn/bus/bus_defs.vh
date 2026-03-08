`define BUS_ADDR_SIZE (`WORD_WIDTH)
`define BUS_ADDR_PORT (`BUS_ADDR_SIZE - 1):0

`define BUS_DATA_SIZE (`WORD_WIDTH)
`define BUS_DATA_PORT (`BUS_DATA_SIZE - 1):0

// master in
`define BUS_MIPORT_SIZE (`BUS_DATA_SIZE + 1 + 1)
`define BUS_MIPORT (`BUS_MIPORT_SIZE - 1):0

`define BUS_MI_DATA   0+:`BUS_DATA_SIZE
`define BUS_MI_ACK    (`BUS_DATA_SIZE + 0)
`define BUS_MI_SEQSLV (`BUS_DATA_SIZE + 1)

// master out
`define BUS_MOPORT_SIZE (`BUS_ADDR_SIZE + `BUS_DATA_SIZE + 1 + 1 + 2 + 1)
`define BUS_MOPORT (`BUS_MOPORT_SIZE - 1):0

`define BUS_MO_DATA   0+:`BUS_DATA_SIZE
`define BUS_MO_ADDR   `BUS_DATA_SIZE+:`BUS_ADDR_SIZE
`define BUS_MO_REQ    (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 0)
`define BUS_MO_SEQMST (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 1)
`define BUS_MO_SIZE   (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 2)+:2
`define BUS_MO_RW     (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 4)

// slave in
`define BUS_SIPORT_SIZE (`BUS_ADDR_SIZE + `BUS_DATA_SIZE + 1 + 1 + 2 + 1)
`define BUS_SIPORT (`BUS_SIPORT_SIZE - 1):0

`define BUS_SI_DATA   0+:`BUS_DATA_SIZE
`define BUS_SI_ADDR   `BUS_DATA_SIZE+:`BUS_ADDR_SIZE
`define BUS_SI_REQ    (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 0)
`define BUS_SI_SEQMST (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 1)
`define BUS_SI_SIZE   (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 2)+:2
`define BUS_SI_RW     (`BUS_DATA_SIZE + `BUS_ADDR_SIZE + 4)

// slave out
`define BUS_SOPORT_SIZE (`BUS_DATA_SIZE + 1 + 1)
`define BUS_SOPORT (`BUS_SOPORT_SIZE - 1):0

`define BUS_SO_DATA   0+:`BUS_DATA_SIZE
`define BUS_SO_ACK    (`BUS_DATA_SIZE + 0)
`define BUS_SO_SEQSLV (`BUS_DATA_SIZE + 1)

`define BUS_READ  (1'b0)
`define BUS_WRITE (1'b1)

`define BUS_SIZE_BYTE   (2'b00)
`define BUS_SIZE_WORD   (2'b01)
`define BUS_SIZE_TWORD  (2'b10)
`define BUS_SIZE_STREAM (2'b11)

// stream
`define STREAM_MOPORT_SIZE(data_size) ((data_size) + 2)
`define STREAM_MOPORT(data_size) `STREAM_MOPORT_SIZE((data_size)) - 1:0

`define STREAM_MIPORT_SIZE(data_size) (1)
`define STREAM_MIPORT(data_size) `STREAM_MIPORT_SIZE((data_size)) - 1:0

`define STREAM_SOPORT_SIZE(data_size) (1)
`define STREAM_SOPORT(data_size) `STREAM_SOPORT_SIZE((data_size)) - 1:0

`define STREAM_SIPORT_SIZE(data_size) ((data_size) + 2)
`define STREAM_SIPORT(data_size) `STREAM_SIPORT_SIZE((data_size)) - 1:0

`define STREAM_MO_DATA(data_size) (data_size) - 1:0
`define STREAM_MO_VALID(data_size) ((data_size) + 0)
`define STREAM_MO_LAST(data_size) ((data_size) + 1)

`define STREAM_MI_READY(data_size) (0)

`define STREAM_SO_READY(data_size) (0)

`define STREAM_SI_DATA(data_size) (data_size) - 1:0
`define STREAM_SI_VALID(data_size) ((data_size) + 0)
`define STREAM_SI_LAST(data_size) ((data_size) + 1)
