interface radar_io(input bit clock);
    parameter DATA_WIDTH = 16;
    logic reset_n;
    logic [10:0] row_idx1;
    logic [10:0] col_idx1;
    logic [10:0] row_idx2;
    logic [10:0] col_idx2;
    logic [3:0] channel_num;
    logic  data_start;
    logic  data_end;
    logic  data_vaild;
    logic [DATA_WIDTH*5*2-1:0] pixel_out; 

    clocking cb@(posedge clock);
        default input #1ns output #1ns;
        output reset_n;
        inout row_idx1;
        inout col_idx1;
        inout row_idx2;
        inout col_idx2;
        inout channel_num;
        inout data_start;
        inout data_end;
        inout pixel_out;
        inout data_vaild;
    endclocking:cb

    modport TB(clocking cb,output reset_n);



endinterface:radar_io