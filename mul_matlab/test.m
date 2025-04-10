%单个数测试
width = 10;
DEC_POINT_POS = 4;
Conf_Bit_Mask = bin2dec('111111');

% A_real = -0.625;
% B_real = -0.5;
A_real = -7.45726586;
B_real = -6.2322576;

A_fixed = round(A_real * 16);  % -10
B_fixed = round(B_real * 16);  % -8

R_fixed = fixed_point_mul(A_fixed, B_fixed, Conf_Bit_Mask, width, DEC_POINT_POS);

% 二补码解码
if R_fixed >= 2^15
    R_signed = R_fixed - 2^16;
else
    R_signed = R_fixed;
end

R_real = R_signed / 16;

fprintf("ApproxResult = %.4f, True = %.4f\n", R_real, A_real * B_real);





