module stimulate(radar_io.TB io);

    // 模拟图像数据存储�?
    reg [io.DATA_WIDTH-1:0] image_mem[io.FRAME_NUM][io.IMG_ROWS-1:0][io.IMG_COLS-1:0];

    integer i, j;
    reg [11:0] row,col;
    reg [2:0 ] wait_cnt ;
    reg [1:0] cnt;


    // 初始化图像数据（仅用于仿真）
    initial begin
        for (i = 0; i < io.IMG_ROWS; i = i + 1) begin
            for (j = 0; j < io.IMG_COLS; j = j + 1) begin
                image_mem[1][i][j] = (i * io.IMG_COLS + j) % (2**io.DATA_WIDTH); // 示例数据
            end
        end
    end

    initial begin
        @(io.cb);
        reset();
        io.cb.data_start <= 1'b1;
        @(io.cb);
        io.cb.data_start <= 1'b0;
    end

    task reset();
        io.reset_n <= 1'b0;
        io.cb.data_start <= 0;
        io.cb.data_end <= 0;
        io.cb.row_idx1 <= 0;
        io.cb.col_idx1 <= 0;
        io.cb.row_idx2 <= 0;
        io.cb.col_idx2 <= 1;
        io.cb.channel_num <= 0;
        wait_cnt <= 0;
        row <= -2;
        col <= -2;
        #10ns;
        io.reset_n <= 1'b1;
        repeat(10)@(io.cb);
    endtask:reset


       // 控制 row/col 的滑动�?�辑
    always@(io.cb or negedge io.reset_n) begin
            if (col < io.IMG_COLS) begin
                    if(col<2 && wait_cnt <2 )begin
                        wait_cnt <= wait_cnt + 1;
                    end else if(col<io.IMG_COLS-2 )begin
                        io.cb.col_idx1 <= col + 1; 
                        io.cb.col_idx2 <= col + 1; 
                    end 
                    col <= col + 2; // 2列滑�?
            end
                    
            else begin
                wait_cnt <= 0;
                col <= -2;
                io.cb.col_idx1 <= 0;
                io.cb.col_idx2 <= 1;
                if (row < io.IMG_ROWS + 1) begin
                    row <= row + 1;
                end else begin
                    row <= 0;
                end
                //真实索引
                if(io.cb.row_idx1 < io.IMG_ROWS-1)begin
                    io.cb.row_idx1 <= io.cb.row_idx1 + 1; 
                    io.cb.row_idx2 <= io.cb.row_idx2 + 1; 
                end else begin
                    io.cb.row_idx1 <= 0;
                end
            end
    end

    always@(io.cb or negedge io.reset_n)begin
        if(io.cb.row_idx1 <2048 && io.cb.col_idx2<2048)begin
               // 数据窗口读取 + 边界�?0
            for(j=0;j<2;j=j+1)begin
                for(i = 0;i<5;i=i+1)begin
                    // 当前逻辑坐标（包括补0区域�?
                    if (row >= 0 && row < io.IMG_ROWS && col >= 0 && col < io.IMG_COLS) begin
                        io.cb.pixel_out[i+j] <= image_mem[io.cb.channel_num][row][col];
                    end else begin
                        io.cb.pixel_out[i+j] <= 0;
                    end
                end
            end
        end else if(io.cb.row_idx1 == 2047 && io.cb.col_idx2 == 2047)begin
            io.cb.data_end <= 1'b1;
            io.cb.channel_num <= io.cb.channel_num + 1;
        end else begin
            io.cb.data_end <= 1'b0;
            io.cb.data_start <= 1'b1;
        end

        if(io.cb.channel_num >4)begin
            io.cb.data_end <= 1'b1;
            io.cb.channel_num <= 4;
            $finish();
        end 
    end

endmodule



