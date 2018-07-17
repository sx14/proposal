function [ucm,ms_struct,new_leaves] = conbine_curr_level(leaves_part, ucm, threshold)
    ucm(ucm <= threshold) = 0;
    temp_ucm = ucm;
    temp_ucm(1:2:end,1:2:end) = 1;              % Make the gridbmap connected
    labels = bwlabel(temp_ucm' == 0, 8);        % Transposed for the scanning to be from
                                                %   left to right and from up to down
                                                % 8 connected, the method will labeled
                                                % all 8-connected-regions in tmp_ucm
    leaf_sum = max(max(leaves_part));
    labels = labels';
    new_leaves = leaves_part;
    new_leaves(:,:) = labels(2:2:end,2:2:end);
    new_leaf_sum = max(max(new_leaves));
    conbine_mat = zeros(new_leaf_sum, leaf_sum);    % 新的叶子由哪些旧的叶子组成
    for i = 1:size(new_leaves,1)
        for j = 1:size(new_leaves,2)
            new_leaf = new_leaves(i,j);
            leaf = leaves_part(i,j);
            conbine_mat(new_leaf,leaf) = conbine_mat(new_leaf,leaf) | 1;
        end
    end
    count = 1;
    for i = 1:new_leaf_sum
        children = find(conbine_mat(i,:) == 1);
        if length(children) > 1 % 孩子大于一个才是一次组合，赋予一个新的label
            ms_struct(count).parent = count+leaf_sum;
            ms_struct(count).children = children;
            new_leaves(new_leaves == i) = count+leaf_sum;
            count = count + 1;
        else % 是同一个sp，不应该有一个新的label，而是使用children的label
            new_leaves(new_leaves == i) = children;
        end
    end
    if count == 1   % 本次没有合并
        ms_struct = zeros(1,0);
    end
%     new_leaves = new_leaves + leaf_sum;
end