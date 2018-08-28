clear;clc;
a = [
[0,1,1,0],
[1,0,0,1],
[1,0,0,1],
[0,1,1,0]
];

c = [
[1,0,0,0],
[0,1,0,0],
[0,0,1,0],
[0,0,0,1],
[1,1,0,0],
[0,0,1,1]
];

cc = c * c';

b = c * a * c';

m = xor(b, cc);

combine_mat = c;
basic_adjacent_mat = a;
adjacent_sp_mat0 = combine_mat * basic_adjacent_mat * combine_mat';
adjacent_sp_mask = adjacent_sp_mat0 & adjacent_sp_mat0;    % 变为0/1矩阵
% 消去组合后的超像素与自己的子超像素相邻
full_combine_mat = combine_mat * combine_mat';
full_combine_mat = full_combine_mat & full_combine_mat;
leaf_sum = size(basic_adjacent_mat, 1);
leaf_diag = eye(leaf_sum);
adjacent_sp_mask(1:leaf_sum, 1:leaf_sum) = adjacent_sp_mask(1:leaf_sum, 1:leaf_sum) + leaf_diag;
adjacent_sp_mask = xor(adjacent_sp_mask, full_combine_mat);

adjacent_sp_mat = adjacent_sp_mat0 .* adjacent_sp_mask;