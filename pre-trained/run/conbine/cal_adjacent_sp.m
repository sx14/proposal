function adjacent_sp_mat = cal_adjacent_sp(leaves_part,conbine_mat)
new_adjacent_mat = cal_adjacent_basic_sp(leaves_part); % 自己与自己不相邻
diag = eye(size(new_adjacent_mat));
new_adjacent_mat = new_adjacent_mat + diag; % 让自己与自己相邻
adjacent_sp_mat = conbine_mat * new_adjacent_mat * conbine_mat';
adjacent_sp_mat = adjacent_sp_mat & adjacent_sp_mat;    % 变为0/1矩阵
% 消去组合后的超像素与自己的子超像素相邻
adjacent_sp_mat(:,1:size(new_adjacent_mat,2)) = xor(adjacent_sp_mat(:,1:size(new_adjacent_mat,2)),conbine_mat);
adjacent_sp_mat(1:size(new_adjacent_mat,1),:) = xor(adjacent_sp_mat(1:size(new_adjacent_mat,1),:),conbine_mat');
adjacent_sp_mat = adjacent_sp_mat - eye(size(adjacent_sp_mat));