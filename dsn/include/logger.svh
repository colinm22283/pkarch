`ifndef LOGGER_SVH
`define LOGGER_SVH

`include "logger_config.svh"

`define DL_NAME_MAX_LEN (256)

`define DL_RED     "\033[31m"
`define DL_GREEN   "\033[32m"
`define DL_YELLOW  "\033[33m"
`define DL_BLUE    "\033[34m"
`define DL_MAGENTA "\033[35m"
`define DL_CYAN    "\033[36m"

`ifdef DL_RANDOM_COLORS
`define DL_DEFINE(name, label, color, enabled) \
    localparam name``_label   = label; \
    wire [5 * 8 - 1:0] name``_colors [4:0]; \
    assign name``_colors[0] = `DL_GREEN; \
    assign name``_colors[1] = `DL_YELLOW; \
    assign name``_colors[2] = `DL_BLUE; \
    assign name``_colors[3] = `DL_MAGENTA; \
    assign name``_colors[4] = `DL_CYAN; \
    wire [5 * 8 - 1:0] name``_color; \
    assign name``_color   = name``_colors[{$random} % 5]; \
    localparam name``_enabled = enabled ? 1'b1 : 1'b0;
`else
`define DL_DEFINE(name, label, color, enabled) \
    localparam name``_label   = label; \
    localparam name``_color   = color; \
    localparam name``_enabled = enabled ? 1'b1 : 1'b0;
`endif

`ifdef DL_ENABLE
`define DL(name, msg) \
    begin \
        if (name``_enabled) begin \
            $display("%s[ %s ] %s\033[0m", name``_color, name``_label, $sformatf msg); \
        end \
    end
`else
`define DL(name, msg) \
    begin end
`endif

`endif

