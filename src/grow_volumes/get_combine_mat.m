function [combine_mat,sp_leaves_mat] = get_combine_mat(hier)
leaves = hier.leaves_part;
small_sp_amount = max(max(leaves));                                 % 上一帧底层超像素个数
all_level_sp_amount = size(hier.ms_matrix,1) + small_sp_amount;     % 上一帧各层超像素总数
combine_mat = zeros(all_level_sp_amount, small_sp_amount);          % 超像素组合矩阵
sp_leaves_mat = zeros(all_level_sp_amount,small_sp_amount);
for i=1:small_sp_amount
    combine_mat(i,i) = 1;
end
sp_leaves_mat(1:small_sp_amount,1) = 1:small_sp_amount;
ms_matrix = hier.ms_matrix;    % 组合的超像素
parent_index = size(ms_matrix,2);
for i=1:size(ms_matrix,1)
    info = ms_matrix(i,:);
    parent = info(parent_index);
    children = info(1:parent_index-1);
    next_children_index = 0;
    for j = 1:size(children,2)
        if children(j) > 0
            [combine_mat,sp_leaves_mat,next_children_index] = fill_combine_matrix(combine_mat,sp_leaves_mat,ms_matrix,parent,children(j),small_sp_amount,next_children_index);
        end
    end
end


% 递归:填充超像素组合矩阵，每个元素代表被包含的超像素（底层）的像素个数/或是否包含超像素（底层）
function [combine_mat,sp_leaves_mat,next_children_index] = fill_combine_matrix(combine_mat, sp_leaves_mat, ms_matrix, parent, children_label, small_sp_amount, next_children_index)
if children_label > small_sp_amount
    info = ms_matrix(children_label-small_sp_amount,:);
    grandsons = info(1:length(info) - 1);
    for i = 1:length(grandsons)
        % 记录是否包含
        if grandsons(i) > 0
            [combine_mat,sp_leaves_mat,next_children_index] = fill_combine_matrix(combine_mat,sp_leaves_mat,ms_matrix,parent,grandsons(i),small_sp_amount,next_children_index);
        end
    end
else
    % 记录是否包含
    next_children_index = next_children_index + 1;
    sp_leaves_mat(parent,next_children_index) = children_label;
	combine_mat(parent,children_label) = 1;
end