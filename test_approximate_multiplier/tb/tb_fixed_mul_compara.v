module tb;

    // 输入信号
    reg [9:0] A;
    reg [9:0] B;
    reg [7:0] Conf_Bit_Mask;  // 可配置精度掩码

    // 输出信号
    wire [19:0] R;

    // 实例化乘法器模块
    fixed_int_mul #(
        .WIDTH(10),          // 输入位宽 10 位
        .DEC_POINT_POS(4)  
    ) uut (
        .A(A),
        .B(B),
        .Conf_Bit_Mask(Conf_Bit_Mask),
        .R(R)
    );

    real total_abs_error = 0.0;
    real max_error = 0.0;
    // 将定点数转换为实数，便于验证输出
    function real fixed_to_real;
        input [9:0] val;
        reg  [8:0] mag;
        begin
            if(val[9] == 1'b1)begin
                mag = (~val[8:0] + 1);
                fixed_to_real = -(mag / 16.0);
            end else begin
                fixed_to_real = val / 16.0; 
            end
        end
    endfunction

   function real out_to_real;
        input [19:0] val;
        reg [19:0] magnitude;
        begin
            if(val[19] == 1'b1)begin
                magnitude = (~val[18:0]+1);
                out_to_real = -(magnitude / 16.0);
            end else begin
                out_to_real = val[18:0]/16.0;
            end
        end
    endfunction


    // 测试用例
    integer i;
    initial begin
        real expected,actual,error,abs_error;
        $display("A\t\tB\t\tR(Expected)\tR(Actual)\t\tError");
        Conf_Bit_Mask = 8'b00000011;

        for(i= 0;i<20480;i=i+1)begin
            A = $random % 33;
            B = A;
            #20;

            expected = fixed_to_real(A) * fixed_to_real(B);
            actual = out_to_real(R);
            error = actual - expected;
            abs_error = (error < 0) ? -error:error;

            total_abs_error = total_abs_error + abs_error;
            if(abs_error > max_error)max_error = abs_error;

             $display("%0f\t%0f\t%0f\t%0f\t\t%0f",fixed_to_real(A),fixed_to_real(B),expected,actual,error);
        end

             $display("\nTest Summary:");
             $display("Total case: %0d",i);
             $display("Average Absolute Error:%f",total_abs_error / i);
             $display("Maximum Absolute Error:%f",max_error);
             $finish;
    end

endmodule
