`timescale 1ns / 1ps

module tb_fp_mul_to_csv;

  reg  [31:0] A, B;
  reg  [21:0] Conf_Bit_Mask;
  wire [31:0] result_exact;
  wire [31:0] result_approx;

  integer fd, i;

  // 实例化精确乘法器
  fp32_mul dut_exact (
    .A(A),
    .B(B),
    .result(result_exact),
    .valid()
  );

  // 实例化近似乘法器
  floating_point_mul dut_approx (
    .A(A),
    .B(B),
    .Conf_Bit_Mask(Conf_Bit_Mask),
    .R(result_approx)
  );

  initial begin
    //Conf_Bit_Mask = 22'b1111111111000000000000;
    Conf_Bit_Mask = 22'b0000000000000000111111;

    fd = $fopen("fp_mul_result.csv", "w");
    $fwrite(fd, "A,B,ExactHex,ApproxHex\n");

    for (i = 0; i < 1000; i = i + 1) begin
      A = $random;
      B = $random;
      #10;
      $fwrite(fd, "%h,%h,%h,%h\n", A, B, result_exact, result_approx);
    end

    $fclose(fd);
    $display("浮点乘法仿真完成，结果保存在 fp_mul_result.csv");
    $finish;
  end

endmodule
