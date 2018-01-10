function combine_mat = get_combine_mat(hier)
leaves = hier.leaves_part;
small_sp_amount = max(max(leaves));                                 % 上一帧底层超像素个数
all_level_sp_amount = size(hier.ms_matrix,1) + small_sp_amount;     % 上一帧各层超像素总数
combine_mat = zeros(all_level_sp_amount, small_sp_amount);          % 超像素组合矩阵
for i=1:small_sp_amount
    combine_mat(i,i) = 1;
end
ms_matrix = hier.ms_matrix;    % 组合的超像素
parent_index = size(ms_matrix,2);
for i=1:size(ms_matrix,1)
    info = ms_matrix(i,:);
    parent = info(parent_index);
    children = info(1:parent_index-1);
    for j = 1:size(children,2)
        if children(j) > 0
            combine_mat = fill_combine_matrix(combine_mat,ms_matrix,parent,children(j),small_sp_amount);
        end
    end
end


% 递归:填充超像素组合矩阵，每个元素代表被包含的超像素（底层）的像素个数/或是否包含超像素（底层）
function combine_mat = fill_combine_matrix(combine_mat, ms_matrix, parent, children_label, small_sp_amount)
if children_label > small_sp_amount
    info = ms_matrix(children_label-small_sp_amount,:);
    grandsons = info(1:length(info) - 1);
    for i = 1:length(grandsons)
        % 记录是否包含
        if grandsons(i) > 0
            combine_mat = fill_combine_matrix(combine_mat,ms_matrix,parent,grandsons(i),small_sp_amount);
        end
    end
else
    % 记录是否包含
	combine_mat(parent,children_label) = 1;
end