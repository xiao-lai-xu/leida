`timescale 1ns/100ps
`include "io.sv"
module tb;
   
    parameter simulation_cycle = 400;
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
        .clk(m_io.cb),
        .rst_n(m_io.reset_n),
        .row_idx1(m_io.cb.row_idx1),
        .col_idx1(m_io.cb.col_idx1),
        .row_idx2(m_io.cb.row_idx2),
        .col_idx2(m_io.cb.col_idx2),
        .channel_num(m_io.cb.channel_num),
        .data_start(m_io.cb.data_start),   
        .data_end(m_io.cb.data_end),
        .pixel_out(m_io.cb.pixel_out)
    );

   endmodule