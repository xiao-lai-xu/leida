module mod_squared_unit(
<<<<<<< HEAD
    input logic signed [15:0] x, //实部
    input logic signed [15:0] y, //虚部
=======
    input [15:0] x,
    input [15:0] y,
>>>>>>> cd02e4a59c9c0a9fb0d18fda6e98954ee0e238aa
    input [7:0] conf_bit_mask,

    
<<<<<<< HEAD
    output reg [31:0] r
);


//--------------------近似乘法器------------------------------------------
    wire [15:0] mul_r1;
    wire [15:0] mul_r2;    

=======
    output reg [30:0] r
);
    wire [30:0] mul_r1;
    wire [30:0] mul_r2;
    
    //----------------------���Ƴ˷���-------------------------------------------------
>>>>>>> cd02e4a59c9c0a9fb0d18fda6e98954ee0e238aa
    fixed_int_mul #(.WIDTH(8), .DEC_POINT_POS(4)) m_fixed_int_mul_x(
        .A(x),
        .B(x),
        .Conf_Bit_Mask(conf_bit_mask),
        .R(mul_r1)
    );
<<<<<<< HEAD

=======
>>>>>>> cd02e4a59c9c0a9fb0d18fda6e98954ee0e238aa
    fixed_int_mul #(.WIDTH(8), .DEC_POINT_POS(4)) m_fixed_int_mul_y(
        .A(y),
        .B(y),
        .Conf_Bit_Mask(conf_bit_mask),
        .R(mul_r2)
    );

    assign r = mul_r1 + mul_r2; //实部平方加虚部平方
    
<<<<<<< HEAD
//----------------------普通乘法-----------------------------------------------
    logic signed [31:0] a2 = x*x;
    logic signed [31:0] b2 = y*y;
    assign r = a2 + b2; //实部平方加虚部平方

=======
    assign  r = mul_r1 + mul_r2;
    
 //------------------------��ͨ�˷�-----------��ģ��------------------------------
 assign mul_r1 = x * x;
 assign mul_r2 = y * y;
 assign r = mul_r1 + mul_r2;



    
>>>>>>> cd02e4a59c9c0a9fb0d18fda6e98954ee0e238aa




endmodule