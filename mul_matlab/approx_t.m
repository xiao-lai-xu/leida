function f = approx_t(x, y, Conf_Bit_Mask, width)
% APPROX_T: 近似乘法的核心算法 (Approx-T)，定义了六个差值项 delta_f0...delta_f5
% 并根据配置位 (Conf_Bit_Mask) 选择性地对它们求和。
%
% x, y 为 (width-1) 位无符号数 (即在 leading_one_detector 处理后得到的“去掉 MSB”部分)。
% Conf_Bit_Mask 为 (width-2) 位，用于控制哪些差值项会被加到结果中。
%
% f 为 2*width 位无符号结果。

N = width * 2;  % 输出的内部累加宽度

% ---- delta_f0 ----
S = (bitshift(1, width-1) + x) + (bitshift(1, width-1) + y);
S_half = floor(double(S) / 2);                     
constant = bitshift(1, width) + bitshift(1, width-3);  
delta_f0 = mod(S + S_half - constant, 2^N);

% ---- delta_f1 ----
val_y1 = bitshift(y, -2);   % floor(y / 4)
constant1 = bitshift(1, width-4);
t_f1 = mod(val_y1 - constant1, 2^N);

x_msb = bitand(x, bitshift(1, width-2)) ~= 0;  % x 的最高位 (width-2)
if x_msb
    delta_f1 = t_f1;
else
    % 取反 + 1 (mod 2^N)
    delta_f1 = mod(-double(t_f1) - 1, 2^N);
end

% ---- delta_f2 ----
val_x2 = bitshift(x, -2);   
constant0_f2 = bitshift(3, width-5);
constant1_f2 = bitshift(1, width-5);

t0_f2 = mod(val_x2 - constant0_f2, 2^N);
t1_f2 = mod(val_x2 - constant1_f2, 2^N);

x_msb = bitand(x, bitshift(1, width-2)) ~= 0;
y_msb = bitand(y, bitshift(1, width-2)) ~= 0;
if x_msb
    if y_msb
        delta_f2 = t0_f2;
    else
        delta_f2 = mod(-double(t0_f2) - 1, 2^N);
    end
else
    if y_msb
        delta_f2 = t1_f2;
    else
        delta_f2 = mod(-double(t1_f2) - 1, 2^N);
    end
end

% ---- delta_f3 ----
val_y3 = bitshift(y, -3);    
constant0_f3 = bitshift(3, width-6);
constant1_f3 = bitshift(1, width-6);

t0_f3 = mod(val_y3 - constant0_f3, 2^N);
t1_f3 = mod(val_y3 - constant1_f3, 2^N);

x_bit = bitand(x, bitshift(1, width-3)) ~= 0; 
y_msb = bitand(y, bitshift(1, width-2)) ~= 0;

if x_bit
    if y_msb
        delta_f3 = t0_f3;
    else
        delta_f3 = t1_f3;
    end
else
    if y_msb
        delta_f3 = mod(-double(t0_f3), 2^N);
    else
        delta_f3 = mod(-double(t1_f3), 2^N);
    end
end

% ---- delta_f4 ----
val_x4 = bitshift(x, -3);
val_x4 = mod(val_x4, 2^(width-5)); 
constant0_f4 = bitshift(3, width-7);
constant1_f4 = bitshift(1, width-7);

t0_f4 = mod(val_x4 - constant0_f4, 2^N);
t1_f4 = mod(val_x4 - constant1_f4, 2^N);

x_bit = bitand(x, bitshift(1, width-3)) ~= 0;
y_bit = bitand(y, bitshift(1, width-3)) ~= 0;

if x_bit
    if y_bit
        delta_f4 = t0_f4;
    else
        delta_f4 = mod(-double(t0_f4), 2^N);
    end
else
    if y_bit
        delta_f4 = t1_f4;
    else
        delta_f4 = mod(-double(t1_f4), 2^N);
    end
end

% ---- delta_f5 ----
val_y5 = bitshift(y, -4);
val_y5 = mod(val_y5, 2^(width-6));
constant0_f5 = bitshift(3, max(width-8, 0));
constant1_f5 = bitshift(1, max(width-8, 0));

t0_f5 = mod(val_y5 - constant0_f5, 2^N);
t1_f5 = mod(val_y5 - constant1_f5, 2^N);

x_bit = bitand(x, bitshift(1, width-4)) ~= 0;
y_bit = bitand(y, bitshift(1, width-3)) ~= 0;

if x_bit
    if y_bit
        delta_f5 = t0_f5;
    else
        delta_f5 = t1_f5;
    end
else
    if y_bit
        delta_f5 = mod(-double(t0_f5), 2^N);
    else
        delta_f5 = mod(-double(t1_f5), 2^N);
    end
end

% ---- 根据 Conf_Bit_Mask 的低 6 位，分 3 组 (sel01, sel23, sel45) ----
sel01 = bitand(Conf_Bit_Mask, 3);               % bits [1:0]
sel23 = bitand(bitshift(Conf_Bit_Mask, -2), 3); % bits [3:2]
sel45 = bitand(bitshift(Conf_Bit_Mask, -4), 3); % bits [5:4]

t_f0_f1 = bit_mask_sel(sel01, delta_f0, delta_f1, N);
t_f2_f3 = bit_mask_sel(sel23, delta_f2, delta_f3, N);
t_f4_f5 = bit_mask_sel(sel45, delta_f4, delta_f5, N);

f = mod(t_f0_f1 + t_f2_f3 + t_f4_f5, 2^N);

end
