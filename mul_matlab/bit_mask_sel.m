function r = bit_mask_sel(sel, x, y, WIDTH)
    % bit_mask_sel: 实现 3:1 多路复用器
    % 参数:
    %   sel: 选择信号 (2 位)
    %   x: 输入值 x (长度为 WIDTH)
    %   y: 输入值 y (长度为 WIDTH)
    %   WIDTH: 数据宽度
    % 返回:
    %   r: 输出值 (长度为 WIDTH)

    % 初始化输出
    r = zeros(1, WIDTH);  % 默认输出为全 0

    % 根据选择信号 sel 选择输出
    switch sel
        case 0  % sel = 2'b00
            r = zeros(1, WIDTH);  % 输出全 0
        case 1  % sel = 2'b01
            r = x;  % 输出 x
        case 3  % sel = 2'b11
            r = x + y;  % 输出 x + y
        otherwise
            r = zeros(1, WIDTH);  % 默认输出全 0
    end
end