program automatic stimulate(radar_io.TB io);
    parameter DATA_WIDTH = 16;
    parameter FRAME_NUM  = 4;
    parameter IMG_ROWS = 2048;
    parameter IMG_COLS = 2048;
    // 妯℃嫙鍥惧儚鏁版嵁�?�樺偍鍣?
    reg [DATA_WIDTH-1:0] image_mem[FRAME_NUM][IMG_ROWS-1:0][IMG_COLS-1:0];
 

    integer i, j,z;
    logic [11:0]  row,col;
    reg [2:0 ] wait_cnt ;
    reg [1:0] cnt1,cnt2;
    logic data_ready;

    // 鍒濆�嬪寲鍥惧儚鏁版嵁锛堜粎鐢ㄤ簬浠跨湡锛�
    initial begin
        data_ready = 0;
        for(z = 0;z<4;z=z+1)begin
        for (i = 0; i < IMG_ROWS; i = i + 1) begin
            for (j = 0; j < IMG_COLS; j = j + 1) begin
                image_mem[z][i][j] = (i * IMG_COLS + j) % (2**DATA_WIDTH); // �?轰緥鏁版�?
            end
        end
        end
        data_ready <= 1'b1;
    end

    initial begin
        wait(data_ready==1);
        @(io.cb);
        reset();
        io.cb.data_start <= 1'b1;
        @(io.cb);
        io.cb.data_start <= 1'b0;

        fork
            get_real_row_col();
            get_row_col();
            send();
        join_none
    end

    task reset();
            @(io.cb);
            io.reset_n <= 1'b0;
            io.cb.data_start <= 0;
            io.cb.data_end <= 0;
            io.cb.row_idx1 <= 2;
            io.cb.col_idx1 <= 2;
            io.cb.row_idx2 <= 2;
            io.cb.col_idx2 <= 3;
            row <= 0;
            col <= 0;
            io.cb.channel_num <= 0;
            wait_cnt <= 0;
            #10ns;
            io.reset_n <= 1'b1;
            repeat(10)@(io.cb);
    endtask:reset


       // 鎺у埗 row/col 鐨勬粦鍔�??昏緫
    
   //从（2�?2）开始到�?2045�?2045�?
        task get_real_row_col();
            forever begin
            @(io.cb);
            if(io.cb.col_idx2<IMG_COLS-3)begin
                if(wait_cnt <2 )begin
                    wait_cnt <= wait_cnt +1;
                end else begin
                    io.cb.col_idx1 <= io.cb.col_idx1 + 2; 
                    io.cb.col_idx2 <= io.cb.col_idx2 + 2; 
                end
            end
            else if(io.cb.row_idx1< IMG_ROWS-3)begin
                io.cb.col_idx1 <= 2;
                io.cb.col_idx2 <= 3;
                wait_cnt <= 0;
                io.cb.row_idx1 <= io.cb.row_idx1 + 1;
                io.cb.row_idx2 <= io.cb.row_idx2 + 1;
            end
            end
        endtask:get_real_row_col

        //获取两列五行的开始坐�?
        task get_row_col();
            forever begin
                @(io.cb);
                if(col < IMG_COLS-2) begin
                    col <= col + 2;  //�?拍输出两�?
                end        
                else if(row< IMG_ROWS-4) begin
                    col <= 0;
                    row <= row +1;
                end
            end
        endtask:get_row_col


 
        task send();
            forever begin
            @(io.cb);
            if(io.cb.row_idx1 < 2045 && io.cb.col_idx2< 2045)begin 
                // 鏁版嵁绐�?彛璇诲彇 + 杈圭晫琛?0
                for(j=0;j<2;j=j+1)begin
                    for(i = 0;i<5;i=i+1)begin
                        int idx = j*5 + i;
                        // 褰撳墠閫昏緫鍧愭爣锛堝寘鎷�琛�0鍖哄煙锛?
                            io.cb.pixel_out[DATA_WIDTH*idx +: DATA_WIDTH] <= image_mem[io.cb.channel_num][row+j][col+i]; 
                    end
                end
            end else if(io.cb.row_idx1 == 2045 && io.cb.col_idx2 == 2045 && col ==2046 && row ==2044)begin
                io.cb.data_end <= 1'b1;
                io.cb.data_start <= 1'b1;
                io.cb.channel_num <= io.cb.channel_num + 1;
                io.cb.row_idx1 <= 2;
                io.cb.col_idx1 <= 2;
                io.cb.row_idx2 <= 2;
                io.cb.col_idx2 <= 3;
                col <= 0;
                row <= 0;
                #10ns;
                io.cb.data_end <= 1'b0;
                io.cb.data_start <= 1'b0;
            end 

            if(io.cb.channel_num >3)begin
                io.cb.data_end <= 1'b1;
                io.cb.channel_num <= 4;
                $finish();
            end 
            end
        endtask:send


endprogram:stimulate



