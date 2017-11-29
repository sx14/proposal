function conbine_mat = get_conbine_mat(hier, sp_pixel_mat)
leaves = hier.leaves_part;
small_sp_amount = max(max(leaves));                % 上一帧底层超像素个数
all_level_sp_amount = size(hier.start_ths,1);     % 上一帧各层超像素总数
conbine_mat = zeros(all_level_sp_amount, small_sp_amount); % 超像素组合矩阵
if nargin < 2
    for i=1:small_sp_amount
        conbine_mat(i,i) = 1;
    end
else    % 组合矩阵填充的是被包含超像素的像素个数
    for i=1:small_sp_amount
        conbine_mat(i,i) = sp_pixel_mat(i,2);
    end
end

conbine_struct = hier.ms_struct;    % 组合的超像素
for i=1:size(conbine_struct,2)
    sp = conbine_struct(i);
    parent = sp.parent;
    children = sp.children;
    for j = 1:size(children,2)
        if nargin < 2
            conbine_mat = fill_conbine_matrix(conbine_mat,conbine_struct,parent,children(j),small_sp_amount);
        else
            conbine_mat = fill_conbine_matrix(conbine_mat,conbine_struct,parent,children(j),small_sp_amount,sp_pixel_mat);
        end
        
    end
end


% 递归:填充超像素组合矩阵，每个元素代表被包含的超像素（底层）的像素个数/或是否包含超像素（底层）
function conbine_mat = fill_conbine_matrix(conbine_mat, conbine_struct, parent, children_label, small_sp_amount, sp_pixel_mat)
if children_label > small_sp_amount
    grandsons = conbine_struct(children_label-small_sp_amount).children;
    for i = 1:size(grandsons,2)
        if nargin > 5   % 统计像素个数
            conbine_mat = fill_conbine_matrix(conbine_mat,conbine_struct,parent,grandsons(i),small_sp_amount, sp_pixel_mat);
        else            % 记录是否包含
            conbine_mat = fill_conbine_matrix(conbine_mat,conbine_struct,parent,grandsons(i),small_sp_amount);
        end
    end
else
    if nargin > 5       % 统计像素个数
        conbine_mat(parent,children_label) = sp_pixel_mat(children_label,2);
    else                % 记录是否包含
        conbine_mat(parent,children_label) = 1;
    end
end