module cfar_input_generator_with_padding #(
    parameter DATA_WIDTH = 16,
    parameter IMG_ROWS   = 2048,
    parameter IMG_COLS   = 2048
)(
    input  wire                     clk,
    input  wire                     rst,

    output reg                      valid_out,
    output reg [11:0]              row_idx,              // 原图中的 row 起点
    output reg [11:0]              col_idx,              // 原图中的 col 起点
    output reg [DATA_WIDTH-1:0]    pixel_out[4:0][1:0]   // 一拍输出 5×2（两列）
);

    // 原图像存储器 
    reg [DATA_WIDTH-1:0] image_mem[0:IMG_ROWS-1][0:IMG_COLS-1];
    reg [11:0] row,col;
    reg wait_cnt [3:0];
    integer i, j;

    // 仿真初始化
    initial begin
        for (i = 0; i < IMG_ROWS; i = i + 1)
            for (j = 0; j < IMG_COLS; j = j + 1)
                //image_mem[i][j] = (i * IMG_COLS + j) % (2**DATA_WIDTH);
                image_mem[i][j] = 1;
    end

    // 控制 row/col 的滑动逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row   <= -2;
            col   <= -2;  // 从 -2 开始
            valid_out <= 0;
        end else begin
            valid_out <= 1;
            if (col < IMG_COLS + 1) begin
                if(col < IMG_COLS-1)begin
                    col <= col + 2; // 2列滑动

                    
                    if(col>2 && wait_cnt<3)begin
                        wait_cnt <= wait_cnt + 1;
                    end else if(col<IMG_COLS+1 && col>IMG_COLS-1)begin
                        wait_cnt <= 0;
                        col_idx <= 0;
                    end else begin
                        //真实列索引
                            col_idx <= col + 1; // 原图中的 col 起点
                        end

                    end
                end
                col <= col + 2;
            end else begin
                col <= -2;
                if (row < IMG_ROWS + 1) begin
                    row <= row + 1;
                end else begin
                    row <= 0;
                end
                //真实索引
                if(row_idx < IMG_ROWS-1)begin
                    row_idx <= row + 1; // 原图中的 row 起点
                end else begin
                    row_idx <= 0;
                end
            end
        end

    // 数据窗口读取 + 边界补0
    always @(posedge clk) begin
        //真实列索引
        if(col_idx < IMG_COLS-1)begin
            col_idx <= col + 1; // 原图中的 col 起点
        end else  begin
            col_idx <= 0;
        end

        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                // 当前逻辑坐标（包括补0区域）
                if (row >= 0 && row < IMG_ROWS && col >= 0 && col < IMG_COLS) begin
                    pixel_out[i][j] <= image_mem[r][c];
                end else begin
                    pixel_out[i][j] <= 0;
                end
            end
        end

    end

endmodule
