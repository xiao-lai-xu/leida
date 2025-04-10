function r = bit_mask_sel(sel, x, y, N)
% BIT_MASK_SEL: 3-to-1 multiplexer controlled by a 2-bit mask.
% sel 为 2 位值：
%   sel=0 或 sel=2 => r = 0
%   sel=1 => r = x
%   sel=3 => r = x + y
% 由于要限制在 N 位宽范围内，所有运算对 2^N 取模。

if sel == 1
    r = mod(x, 2^N);
elseif sel == 3
    r = mod(x + y, 2^N);
else
    r = 0;
end

end
