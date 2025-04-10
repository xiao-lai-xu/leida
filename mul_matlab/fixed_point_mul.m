function R = fixed_point_mul(A, B, Conf_Bit_Mask, width, DEC_POINT_POS)
    % Step 1: 符号判断
    signA = A < 0;
    signB = B < 0;
    signR = xor(signA, signB);

    % Step 2: 取绝对值
    mag_A = abs(A);
    mag_B = abs(B);

    % Step 3: 用 unsigned 近似乘法器计算乘积
    mag_R = unsigned_int_mul(mag_A, mag_B, Conf_Bit_Mask, width);

    % Step 4: 应用符号
    if signR
        R_signed = -double(mag_R);
    else
        R_signed = double(mag_R);
    end

    % Step 5: 固定小数位移位处理
    R_val = floor(R_signed / 2^DEC_POINT_POS);

    % Step 6: 返回二补码格式的输出（方便和 Verilog 对齐）
    if R_val < 0
        R = R_val + 2^(2 * width);
    else
        R = R_val;
    end
end
