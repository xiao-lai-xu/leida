function pos = leading_one_detector(num, width)
% LEADING_ONE_DETECTOR: 寻找 num 在 width 位二进制表示中最高有效 '1' 的位置。
% 返回值为 0 表示最低位 (LSB)，width-1 表示最高位 (MSB)。
% 如果 num=0，则默认返回 0。

pos = 0;
for i = width-1:-1:0
    if bitand(num, bitshift(1, i)) ~= 0
        pos = i;
        break;
    end
end

end
