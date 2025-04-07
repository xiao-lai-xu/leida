function f = approx_t(x, y, Conf_Bit_Mask, WIDTH)
    % approx_t: 实现近似乘法器
    % 参数:
    %   x: 输入值 x (长度为 WIDTH-1)
    %   y: 输入值 y (长度为 WIDTH-1)
    %   Conf_Bit_Mask: 配置位掩码 (长度为 WIDTH-3)
    %   WIDTH: 数据宽度
    % 返回:
    %   f: 近似乘法结果 (长度为 2*WIDTH)

    % delta_f(0)
    delta_f0 = (bitshift(1, WIDTH-1) + x) + (bitshift(1, WIDTH-1) + y) ...
             + bitshift((bitshift(1, WIDTH-1) + x) + (bitshift(1, WIDTH-1) + y), -1) ...
             - bitshift(2, WIDTH-2) - bitshift(1, WIDTH-3);

    % delta_f(1)
    if y(WIDTH-1) == 1
        t_f1 = [~y(WIDTH-1), y(WIDTH-2:-1:2)];
    else
        t_f1 = [ones(1, WIDTH+3), ~y(WIDTH-1), y(WIDTH-2:-1:2)];
    end
    if x(WIDTH-1) == 1
        delta_f1 = t_f1;
    else
        delta_f1 = ~t_f1;
    end

    % delta_f(2)
    t0_f2 = compute_t_f2(x, WIDTH, 0);
    t1_f2 = compute_t_f2(x, WIDTH, 1);
    if x(WIDTH-1) == 1
        if y(WIDTH-1) == 1
            delta_f2 = t0_f2;
        else
            delta_f2 = ~t0_f2;
        end
    else
        if y(WIDTH-1) == 1
            delta_f2 = t1_f2;
        else
            delta_f2 = ~t1_f2;
        end
    end

    % delta_f(3)
    t0_f3 = compute_t_f3(y, WIDTH, 0);
    t1_f3 = compute_t_f3(y, WIDTH, 1);
    if x(WIDTH-2) == 1
        if y(WIDTH-1) == 1
            delta_f3 = t0_f3;
        else
            delta_f3 = t1_f3;
        end
    else
        if y(WIDTH-1) == 1
            delta_f3 = ~t0_f3 + 1;
        else
            delta_f3 = ~t1_f3 + 1;
        end
    end

    % delta_f(4)
    t0_f4 = compute_t_f4(x, WIDTH, 0); %
    t1_f4 = compute_t_f4(x, WIDTH, 1);
    if x(WIDTH-2) == 1
        if y(WIDTH-2) == 1
            delta_f4 = t0_f4;
        else
            delta_f4 = ~t0_f4 + 1;
        end
    else
        if y(WIDTH-2) == 1
            delta_f4 = t1_f4;
        else
            delta_f4 = ~t1_f4 + 1;
        end
    end

    % delta_f(5)
    t0_f5 = compute_t_f5(y, WIDTH, 0);
    t1_f5 = compute_t_f5(y, WIDTH, 1);
    if x(WIDTH-3) == 1
        if y(WIDTH-2) == 1
            delta_f5 = t0_f5;
        else
            delta_f5 = t1_f5;
        end
    else
        if y(WIDTH-2) == 1
            delta_f5 = ~t0_f5 + 1;
        else
            delta_f5 = ~t1_f5 + 1;
        end
    end

    % Combine results based on Conf_Bit_Mask
    t_f0_f1 = bit_mask_sel(Conf_Bit_Mask(1:2), delta_f0, delta_f1, WIDTH*2);
    t_f2_f3 = bit_mask_sel(Conf_Bit_Mask(3:4), delta_f2, delta_f3, WIDTH*2);
    t_f4_f5 = bit_mask_sel(Conf_Bit_Mask(5:6), delta_f4, delta_f5, WIDTH*2);

    % Final result
    f = t_f0_f1 + t_f2_f3 + t_f4_f5;
end

function t_f2 = compute_t_f2(x, WIDTH, mode)
    if mode == 0
        % t0_f2 的逻辑
        if x(WIDTH-1:WIDTH-2) == [1, 1]  % x[WIDTH-2:WIDTH-3] == 2'b11
            t_f2 = [~x(WIDTH-1:WIDTH-2), x(WIDTH-3:-1:2)];
        elseif x(WIDTH-1:WIDTH-2) == [1, 0]  % x[WIDTH-2:WIDTH-3] == 2'b10
            t_f2 = [ones(1, WIDTH+3), x(WIDTH-1), ~x(WIDTH-2), x(WIDTH-3:-1:2)];
        elseif x(WIDTH-1:WIDTH-2) == [0, 1]  % x[WIDTH-2:WIDTH-3] == 2'b01
            t_f2 = [ones(1, WIDTH+3), ~x(WIDTH-1), x(WIDTH-2), x(WIDTH-3:-1:2)];
        else  % x[WIDTH-2:WIDTH-3] == 2'b00
            t_f2 = [ones(1, WIDTH+3), ~x(WIDTH-1), ~x(WIDTH-2), x(WIDTH-3:-1:2)];
        end
    else
        % t1_f2 的逻辑
        if any(x(WIDTH-1:WIDTH-2))  % |x[WIDTH-2:WIDTH-3] == 1'b1
            t_f2 = [x(WIDTH-1), ~x(WIDTH-2), x(WIDTH-3:-1:2)];
        else
            t_f2 = [ones(1, WIDTH+3), ~x(WIDTH-1), ~x(WIDTH-2), x(WIDTH-3:-1:2)];
        end
    end
end

function t_f3 = compute_t_f3(y, WIDTH, mode)
   if mode == 0
        % t0_f3 的逻辑
        if isequal(y(WIDTH-1:WIDTH-2), [1, 1])  % y[WIDTH-2:WIDTH-3] == 2'b11
            t_f3 = [~y(WIDTH-1:WIDTH-2), y(WIDTH-3:-1:3)];
        elseif isequal(y(WIDTH-1:WIDTH-2), [1, 0])  % y[WIDTH-2:WIDTH-3] == 2'b10
            t_f3 = [ones(1, WIDTH+4), y(WIDTH-1), ~y(WIDTH-2), y(WIDTH-3:-1:3)];
        elseif isequal(y(WIDTH-1:WIDTH-2), [0, 1])  % y[WIDTH-2:WIDTH-3] == 2'b01
            t_f3 = [ones(1, WIDTH+4), ~y(WIDTH-1), y(WIDTH-2), y(WIDTH-3:-1:3)];
        else  % y[WIDTH-2:WIDTH-3] == 2'b00
            t_f3 = [ones(1, WIDTH+4), ~y(WIDTH-1), ~y(WIDTH-2), y(WIDTH-3:-1:3)];
        end
    else
        % t1_f3 的逻辑
        if any(y(WIDTH-1:WIDTH-2))  % |y[WIDTH-2:WIDTH-3] == 1'b1
            t1_f3 = [y(WIDTH-1), ~y(WIDTH-2), y(WIDTH-3:-1:3)];
        else
            t1_f3 = [ones(1, WIDTH+4), ~y(WIDTH-1), ~y(WIDTH-2), y(WIDTH-3:-1:3)];
        end
    end
end

function t_f4 = compute_t_f4(x, WIDTH, mode)
    if mode == 0
        % t0_f4 的逻辑
        if isequal(x(WIDTH-3:WIDTH-4), [1, 1])  % x[WIDTH-3:WIDTH-4] == 2'b11
            t_f4 = [~x(WIDTH-3:WIDTH-4), x(WIDTH-5:-1:3)];
        elseif isequal(x(WIDTH-3:WIDTH-4), [1, 0])  % x[WIDTH-3:WIDTH-4] == 2'b10
            t_f4 = [ones(1, WIDTH+5), x(WIDTH-3), ~x(WIDTH-4), x(WIDTH-5:-1:3)];
        elseif isequal(x(WIDTH-3:WIDTH-4), [0, 1])  % x[WIDTH-3:WIDTH-4] == 2'b01
            t_f4 = [ones(1, WIDTH+5), ~x(WIDTH-3), x(WIDTH-4), x(WIDTH-5:-1:3)];
        else  % x[WIDTH-3:WIDTH-4] == 2'b00
            t_f4 = [ones(1, WIDTH+5), ~x(WIDTH-3), ~x(WIDTH-4), x(WIDTH-5:-1:3)];
        end
    else
        % t1_f4 的逻辑
        if any(x(WIDTH-3:WIDTH-4))  % |x[WIDTH-3:WIDTH-4] == 1'b1
            t_f4 = [x(WIDTH-3), ~x(WIDTH-4), x(WIDTH-5:-1:3)];
        else
            t_f4 = [ones(1, WIDTH+5), ~x(WIDTH-3), ~x(WIDTH-4), x(WIDTH-5:-1:3)];
        end
    end
end

function t_f5 = compute_t_f5(y, WIDTH, mode)
    if mode == 0
        % t0_f5 的逻辑
        if isequal(y(WIDTH-3:WIDTH-4), [1, 1])  % y[WIDTH-3:WIDTH-4] == 2'b11
            t_f5 = [~y(WIDTH-3:WIDTH-4)];
        elseif isequal(y(WIDTH-3:WIDTH-4), [1, 0])  % y[WIDTH-3:WIDTH-4] == 2'b10
            t_f5 = [ones(1, WIDTH+6), y(WIDTH-3), ~y(WIDTH-4)];
        elseif isequal(y(WIDTH-3:WIDTH-4), [0, 1])  % y[WIDTH-3:WIDTH-4] == 2'b01
            t_f5 = [ones(1, WIDTH+6), ~y(WIDTH-3), y(WIDTH-4)];
        else  % y[WIDTH-3:WIDTH-4] == 2'b00
            t_f5 = [ones(1, WIDTH+6), ~y(WIDTH-3), ~y(WIDTH-4)];
        end
    else
        % t1_f5 的逻辑
        if any(y(WIDTH-3:WIDTH-4))  % |y[WIDTH-3:WIDTH-4] == 1'b1
            t_f5 = [y(WIDTH-3), ~y(WIDTH-4)];
        else
            t_f5 = [ones(1, WIDTH+6), ~y(WIDTH-3), ~y(WIDTH-4)];
        end
    end
end