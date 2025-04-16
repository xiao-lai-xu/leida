module fp32_mul(
    input [31:0] A,
    input [31:0] B,
    output [31:0] result,
    output valid
);

    wire sign_a, sign_b, sign_r;
    wire [7:0] exp_a, exp_b;
    wire [8:0] exp_r; // 可能溢出，所以用 9 位
    wire [23:0] frac_a, frac_b;
    wire [47:0] frac_mult;

    assign sign_a = A[31];
    assign sign_b = B[31];
    assign sign_r = sign_a ^ sign_b;

    assign exp_a = A[30:23];
    assign exp_b = B[30:23];
    assign exp_r = exp_a + exp_b - 8'd127;

    assign frac_a = {1'b1, A[22:0]};
    assign frac_b = {1'b1, B[22:0]};
    assign frac_mult = frac_a * frac_b;

    // 规格化处理
    wire [22:0] frac_norm;
    wire [8:0] exp_norm;
    wire round_bit = frac_mult[47];
    assign frac_norm = round_bit ? frac_mult[46:24] : frac_mult[45:23];
    assign exp_norm  = round_bit ? exp_r + 1 : exp_r;

    // 溢出 / 下溢处理
    wire overflow  = (exp_norm >= 9'd255);
    wire underflow = (exp_norm <= 9'd0);

    wire [31:0] result_normal = {sign_r, exp_norm[7:0], frac_norm};
    wire [31:0] result_inf    = {sign_r, 8'hFF, 23'd0};
    wire [31:0] result_zero   = 32'd0;

    assign result = overflow ? result_inf :
                    underflow ? result_zero :
                    result_normal;

    assign valid = ~(overflow | underflow);

endmodule
