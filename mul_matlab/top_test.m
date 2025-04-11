% width = 10;
% DEC_POINT_POS = 4;
width = 15;
DEC_POINT_POS = 8;
Conf_Bit_Mask = bin2dec('111111');

% vals = -8:0.25:7.75;
% vals = -128:1/256:127.99609375;
vals = -10:1/128:10.99609375;
err_list = [];

for A = vals
    for B = vals
        A_fixed = round(A * 2^DEC_POINT_POS);
        B_fixed = round(B * 2^DEC_POINT_POS);
        R_fixed = fixed_point_mul(A_fixed, B_fixed, Conf_Bit_Mask, width, DEC_POINT_POS);

        % Decode
        if R_fixed >= 2^(2*width - 1)
            R_signed = R_fixed - 2^(2*width);
        else
            R_signed = R_fixed;
        end
        R_real = R_signed / 2^DEC_POINT_POS;

        true_result = A*B;
        err = R_real - true_result;

        % fprintf("A = %7.4f, B = %7.4f,  Approx = %9.4f,  True = %9.4f,  Error = %+8.4f\n", ...
        %         A, B, R_real, true_result, err);

        err_list(end+1) = err;
    end
end

fprintf("平均绝对误差：%.4f\n", mean(abs(err_list)));
fprintf("最大误差：%.4f\n", max(abs(err_list)));
