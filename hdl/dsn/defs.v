`define BUS_PORT_SIZE (32 + 32 + 2 + 1 + 1 + 1)
`define BUS_PORT `BUS_PORT_SIZE - 1:0

`define BUS_ADDR 31:0
`define BUS_DATA 63:32
`define BUS_SIZE 65:64
`define BUS_RW   66
`define BUS_REQ  67
`define BUS_ACK  68

