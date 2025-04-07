
module fixed_int_mul
#(parameter WIDTH = 8,          //Default WIDTH = 8
  parameter DEC_POINT_POS = 4) 
(
    input [WIDTH-1:0]A,
    input [WIDTH-1:0]B,
    
    input [WIDTH-3:0]Conf_Bit_Mask,  //Support for configurable procision
    
    output [2*WIDTH-1:0]R
 );
    wire [WIDTH-2:0]mag_A, mag_B;
    
    assign mag_A = A[WIDTH-1]? ~A[WIDTH-2:0]+1 : A[WIDTH-2:0];
    assign mag_B = B[WIDTH-1]? ~B[WIDTH-2:0]+1 : B[WIDTH-2:0];
    
    wire [WIDTH*2-1:0] mag_R;
    //----------------------------------------------------------------------------------------------------------------------------
    //unsigned_int_mul m_unsigned_int_mul(.A({1'b0,mag_A}),.B({1'b0,mag_B}),.Conf_Bit_Mask(Conf_Bit_Mask),.R(mag_R));
    wire [$clog2(WIDTH)-1:0] a_ho_pos,b_ho_pos; // a/b highest one position
    wire [$clog2(WIDTH):0]   ab_ho_pos;

   // leading_one_detector #(WIDTH) lod_a(.num(A),.position(a_ho_pos));
  
    integer i_a;
    reg [$clog2(WIDTH)-1:0] reg_position_a;
    reg find_a;
    always @(*) begin
        reg_position_a = 0;
        find_a = 0;
        for (i_a = 1; i_a <= WIDTH; i_a = i_a + 1) begin
            if (A[WIDTH-i]&~find) begin
                reg_position_a = WIDTH-i;        
                find_a = 1'b1;
            end
        end
    end
    assign a_ho_pos = reg_position_a;

 // leading_one_detector #(WIDTH) lod_b(.num(B),.position(b_ho_pos));
    integer i_b;
    reg [$clog2(WIDTH)-1:0] reg_position_b;
    reg find_b;
    always @(*) begin
        reg_position_b = 0;
        find_b = 0;
        for (i_b = 1; i_b <= WIDTH; i_b = i_b + 1) begin
            if (A[WIDTH-i]&~find) begin
                reg_position_b = WIDTH-i_b;        
                find_b = 1'b1;
            end
        end
    end
 
    assign a_ho_pos = reg_position_b;

    assign ab_ho_pos = a_ho_pos + b_ho_pos;
    
    //SHIFTER
    wire [WIDTH-2:0] w_A,w_B;
    assign w_A = A << ~a_ho_pos;    // Shift left to let leading one disappear at the most significant bit (MSB)
    assign w_B = B << ~b_ho_pos;    // Shift left to let leading one disappear at the most significant bit (MSB)
    
    //APPROX-T
    wire [WIDTH*2-1:0] f;
    approx_t #(WIDTH) m_approx_t(.x(w_A),.y(w_B),.Conf_Bit_Mask(Conf_Bit_Mask),.f(f));
    
    //Final Shifter
    assign R = ((|A)&(|B))?
                           (ab_ho_pos[$clog2(WIDTH)] ? ({f,1'b0}<<ab_ho_pos[$clog2(WIDTH)-1:0]) 
                                                     : (     f >>~ab_ho_pos[$clog2(WIDTH)-1:0]))
                          :16'b0;
    //assign mag_R = {1'b0,mag_A} * {1'b0,mag_B};  //for test

    //---------------------------------------------------------------------------------------------------------------------------



    wire  sign_R;
    assign sign_R = A[WIDTH-1] ^ B[WIDTH-1];
    
    wire [2*WIDTH-1:0] R0;
    assign R0 = sign_R?{1'b1,~mag_R[WIDTH*2-2:0]+1}:mag_R;
    assign R = R0 >> DEC_POINT_POS;
    
endmodule
