function position = leading_one_detector(num)
% leading_one_detector - Return the highest '1' position in a binary vector
% Author: Y
% Date: 2024/5/29
% Input:  num - A binary row vector (e.g., [0 1 0 1 1 0 0 0])
% Output: position - Index of the highest '1' (0-based from right, like Verilog)

    WIDTH = length(num);
    position = 0;  % Default value
    find = false;

    for i = 1:WIDTH
        if num(WIDTH - i + 1) == 1 && ~find
            position = WIDTH - i;  % 0-based position
            find = true;
        end
    end
end