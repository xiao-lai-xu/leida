`timescale 1ns/100ps
`include "io_.sv"
module tb;
   
    parameter simulation_cycle = 900;
    bit SystemClock;
    
    initial begin
        $timeformat(-9,1,"ns",10);
        SystemClock = 0;
        forever begin
            #(simulation_cycle/2) SystemClock = ~SystemClock;
        end
    end

    radar_io m_io(SystemClock);
    stimulate m_stimulate(m_io);

    dut m_dut(
        .clk(m_io.clock),
        .rst_n(m_io.reset_n),
        .row_idx1(m_io.row_idx1),
        .col_idx1(m_io.col_idx1),
        .row_idx2(m_io.row_idx2),
        .col_idx2(m_io.col_idx2),
        .channel_num(m_io.channel_num),
        .data_start(m_io.data_start),   
        .data_end(m_io.data_end),
        .data_vaild(m_io.data_vaild),
        .pixel_out(m_io.pixel_out)
    );

   endmodule