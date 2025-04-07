module mod_squared_unit(
    input [15:0] x,
    input [15:0] y,
    input [7:0] conf_bit_mask,
    
    output reg [30:0] r
);
    wire [30:0] mul_r1;
    wire [30:0] mul_r2;
    
    //----------------------近似乘法器-------------------------------------------------
    fixed_int_mul #(.WIDTH(8), .DEC_POINT_POS(4)) m_fixed_int_mul_x(
        .A(x),
        .B(x),
        .Conf_Bit_Mask(conf_bit_mask),
        .R(mul_r1)
    );
    fixed_int_mul #(.WIDTH(8), .DEC_POINT_POS(4)) m_fixed_int_mul_y(
        .A(y),
        .B(y),
        .Conf_Bit_Mask(conf_bit_mask),
        .R(mul_r2)
    );
    
    assign  r = mul_r1 + mul_r2;
    
 //------------------------普通乘法-----------求模方------------------------------
 assign mul_r1 = x * x;
 assign mul_r2 = y * y;
 assign r = mul_r1 + mul_r2;



    




endmodule