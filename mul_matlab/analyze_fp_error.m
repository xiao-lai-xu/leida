function analyze_fp_error(filename)
    % 强制按字符串读取
    opts = detectImportOptions(filename, 'FileType', 'text');
    opts = setvartype(opts, 'char');
    data = readtable(filename, opts);

    % 字符串去空格 + 补齐8位
    A_hex      = pad(strtrim(data.A),         8, 'left', '0');
    B_hex      = pad(strtrim(data.B),         8, 'left', '0');
    Exact_hex  = pad(strtrim(data.ExactHex),  8, 'left', '0');
    Approx_hex = pad(strtrim(data.ApproxHex), 8, 'left', '0');

    % 字符串十六进制 -> uint32 -> float
    A       = typecast(uint32(hex2dec(A_hex)), 'single');
    B       = typecast(uint32(hex2dec(B_hex)), 'single');
    Exact   = typecast(uint32(hex2dec(Exact_hex)), 'single');
    Approx  = typecast(uint32(hex2dec(Approx_hex)), 'single');

    % 误差计算
    abs_err = abs(Exact - Approx);
    rel_err = abs_err ./ abs(Exact);
    rel_err(abs(Exact) < 1e-8) = NaN;  % 忽略接近0的除法

    % 显示前几项结果
    fprintf('\n%-10s %-10s %-12s %-12s %-12s %-12s\n', ...
            'A', 'B', 'Exact', 'Approx', 'AbsErr', 'RelErr');
    for i = 1:min(10, numel(A))
        fprintf('%10.4f %10.4f %12.6f %12.6f %12.2e %12.2e\n', ...
            A(i), B(i), Exact(i), Approx(i), abs_err(i), rel_err(i));
    end

    % 可视化
    figure;
    subplot(1,2,1);
    histogram(abs_err, 50);
    title('Absolute Error');

    subplot(1,2,2);
    histogram(rel_err, 50);
    title('Relative Error');

    % 统计输出
    fprintf('\n[统计信息]\n');
    fprintf('平均绝对误差: %e\n', mean(abs_err, 'omitnan'));
    fprintf('最大相对误差: %e\n', max(rel_err, [], 'omitnan'));
    fprintf('有效样本数: %d\n', sum(~isnan(rel_err)));
end
