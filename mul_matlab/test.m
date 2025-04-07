% 参数设置
WIDTH = 16;  % 数据宽度
x = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];  % 输入 x
y = [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];  % 输入 y

% 测试不同的选择信号
sel = 0;  % sel = 2'b00
r = bit_mask_sel(sel, x, y, WIDTH);
disp(['sel = 0, r = ', mat2str(r)]);

sel = 1;  % sel = 2'b01
r = bit_mask_sel(sel, x, y, WIDTH);
disp(['sel = 1, r = ', mat2str(r)]);

sel = 3;  % sel = 2'b11
r = bit_mask_sel(sel, x, y, WIDTH);
disp(['sel = 3, r = ', mat2str(r)]);