module cfar_input_generator_simple #(
    parameter DATA_WIDTH = 16,
    parameter FRAME_NUM  = 1,                // 图像帧数
    parameter IMG_ROWS   = 2048,
    parameter IMG_COLS   = 2048
)(
    input  wire                     clk,
    input  wire                     rst,

    output reg                      valid_out,
    output reg [11:0]               row_idx,              // 当前起始行索引
    output reg [11:0]               col_idx,              // 当前左列索引
    output reg [DATA_WIDTH-1:0]     pixel_out[4:0][1:0]   // 5×2 输出数据：5行×2列
);

    // 模拟图像数据存储器
    reg [DATA_WIDTH-1:0] image_mem[FRAME_NUM][IMG_ROWS-1:0][IMG_COLS-1:0];

    integer i, j;

    // 初始化图像数据（仅用于仿真）
    initial begin
        for (i = 0; i < IMG_ROWS; i = i + 1) begin
            for (j = 0; j < IMG_COLS; j = j + 1) begin
                image_mem[0][i][j] = (i * IMG_COLS + j) % (2**DATA_WIDTH); // 示例数据
            end
        end
    end

    // 行列索引生成逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row_idx <= 0;
            col_idx <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= 1;
            if (col_idx < IMG_COLS - 2) begin
                col_idx <= col_idx + 1;
            end else begin
                col_idx <= 0;
                if (row_idx < IMG_ROWS - 5) begin
                    row_idx <= row_idx + 1;
                end else begin
                    row_idx <= 0;
                end
            end
        end
    end

    // 提取 5×2 数据块（包含边界处理）
    always @(posedge clk) begin
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                // 行边界处理
                if (row_idx + i < 2) begin
                    pixel_out[i][j] <= image_mem[0][0][col_idx + j]; // 上边界
                end else if (row_idx + i >= IMG_ROWS) begin
                    pixel_out[i][j] <= image_mem[0][IMG_ROWS-1][col_idx + j]; // 下边界
                end else begin
                    // 列边界处理
                    if (col_idx + j < 2) begin
                        pixel_out[i][j] <= image_mem[0][row_idx + i][0]; // 左边界
                    end else if (col_idx + j >= IMG_COLS) begin
                        pixel_out[i][j] <= image_mem[0][row_idx + i][IMG_COLS-1]; // 右边界
                    end else begin
                        pixel_out[i][j] <= image_mem[0][row_idx + i][col_idx + j]; // 正常区域
                    end
                end
            end
        end
    end

endmodule