% 计算所有超像素的相邻关系矩阵
% 计算所有超像素的bbox
function [adjacent_sp_mat,sp_boxes] = cal_adjacent_sp(leaves_part,conbine_mat)
[basic_adjacent_mat,basic_sp_boxes] = cal_adjacent_basic_sp(leaves_part); % 自己与自己不相邻
sp_boxes = get_sp_boxes(basic_sp_boxes, conbine_mat);
diag = eye(size(basic_adjacent_mat));
basic_adjacent_mat = basic_adjacent_mat + diag; % 让自己与自己相邻
adjacent_sp_mat = conbine_mat * basic_adjacent_mat * conbine_mat';
adjacent_sp_mat = adjacent_sp_mat & adjacent_sp_mat;    % 变为0/1矩阵
% 消去组合后的超像素与自己的子超像素相邻
adjacent_sp_mat(:,1:size(basic_adjacent_mat,2)) = xor(adjacent_sp_mat(:,1:size(basic_adjacent_mat,2)),conbine_mat);
adjacent_sp_mat(1:size(basic_adjacent_mat,1),:) = xor(adjacent_sp_mat(1:size(basic_adjacent_mat,1),:),conbine_mat');
adjacent_sp_mat = adjacent_sp_mat - eye(size(adjacent_sp_mat));