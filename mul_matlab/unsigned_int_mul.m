function R = unsigned_int_mul(A, B, Conf_Bit_Mask, width)
% UNSIGNED_INT_MUL: 利用 Approx-T 实现无符号整数乘法。
% A, B 为 width 位无符号数。
% Conf_Bit_Mask 用于控制近似乘法的精度。
% 返回 R 为 2*width 位结果。

N = width * 2;

% 找到 A, B 最高有效位( MSB )的位置
a_pos = leading_one_detector(A, width);
b_pos = leading_one_detector(B, width);

% 归一化 A, B，使得最高 '1' 位移动到 MSB 处
w_A = bitshift(A, (width-1) - a_pos);
w_B = bitshift(B, (width-1) - b_pos);

% 去掉隐含的 1（只保留 width-1 位小数）
w_A = bitand(w_A, bitshift(1, width-1) - 1);
w_B = bitand(w_B, bitshift(1, width-1) - 1);

% 用近似乘法器对归一化后的分数部分做运算
f = approx_t(w_A, w_B, Conf_Bit_Mask, width);

% 去归一化，根据 a_pos + b_pos 调整结果
if (A == 0) || (B == 0)
    R = 0;
else
    ab_pos = a_pos + b_pos;
    if ab_pos >= width
        % 如果 MSB 累加 >= width，表示结果有溢出，需要左移
        shift_amt = ab_pos - (width - 1);
        R = mod(double(f) * 2^shift_amt, 2^N);
    else
        % 否则右移
        shift_amt = (width - 1) - ab_pos;
        % 做“算术”解释：f 可能是 2*width 位，但这里仍以无符号来做
        R_val = floor(double(f) / 2^shift_amt);
        R = mod(R_val, 2^N);
    end
end

end
