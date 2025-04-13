module dut#(
    parameter DATA_WIDTH = 16
)(
    input  wire                        clk,
    input  wire                        rst_n,
    input   [10:0]                     row_idx1,
    input   [10:0]                     col_idx1,
    input   [10:0]                     row_idx2,
    input   [10:0]                     col_idx2,
    input   [3:0]                      channel_num,
    input                              data_start,
    input                              data_end,
    input                              data_vaild,
    input   [DATA_WIDTH*5*2-1:0]       pixel_out
);




endmodule

