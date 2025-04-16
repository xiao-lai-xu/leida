module mod_squared_unit(
    input clk,
    input reset,
    input [14:0] x,
    input [14:0] y,
    input [7:0] conf_bit_mask,
    
    output reg [29:0] r
);
    wire [29:0] mul_r;
    wire [29:0] mul_r1;
    
    fixed_int_mul #(.WIDTH(8), .DEC_POINT_POS(4)) m_fixed_int_mul(
        .A(x),
        .B(y),
        .Conf_Bit_Mask(conf_bit_mask),
        .R(mul_r)
    );
    
    bit_mask_sel #(.WIDTH(16)) m_bit_mask_sel(
        .sel(conf_bit_mask[1:0]),
        .x(mul_r),
        .y(16'b0),
        .r(mul_r1)
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r <= 16'b0;
        end else begin
            r <= mul_r1;
        end
    end





endmodule