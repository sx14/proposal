% 计算所有超像素的相邻关系矩阵
% 计算所有超像素的bbox
% 计算所有超像素的boundary connectivity
% 计算所有超像素的像素个数
function [adjacent_sp_mat,sp_boxes,sp_boundary_connectivity, sp_pixel_num] = cal_adjacent_sp(leaves_part,conbine_mat)
[basic_adjacent_mat,basic_sp_boxes,basic_sp_boundary_pixel_num, basic_sp_pixel_num] = cal_adjacent_basic_sp(leaves_part); % 自己与自己不相邻
sp_boxes = get_sp_boxes(basic_sp_boxes, conbine_mat);
diag = eye(size(basic_adjacent_mat));
basic_adjacent_mat = basic_adjacent_mat + diag;         % 让自己与自己相邻
adjacent_sp_mat = conbine_mat * basic_adjacent_mat * conbine_mat';
adjacent_sp_mat = adjacent_sp_mat & adjacent_sp_mat;    % 变为0/1矩阵
% 消去组合后的超像素与自己的子超像素相邻
full_conbine_mat = conbine_mat * conbine_mat';
full_conbine_mat = full_conbine_mat & full_conbine_mat;
adjacent_sp_mat = xor(adjacent_sp_mat,full_conbine_mat);

sp_boundary_pixel_num = conbine_mat * basic_sp_boundary_pixel_num;
sp_pixel_num = conbine_mat * basic_sp_pixel_num;
sp_boundary_connectivity =  sp_boundary_pixel_num ./ sqrt(sp_pixel_num);