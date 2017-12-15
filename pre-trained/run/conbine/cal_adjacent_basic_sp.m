function adjacent_mat = cal_adjacent_basic_sp(leaves)
basic_sp_sum = max(max(leaves));
adjacent_mat = zeros(basic_sp_sum, basic_sp_sum);
for i = 1:size(leaves, 1)   % 沿水平方向扫描
    for j = 1:size(leaves,2) -1
        sp1 = leaves(i,j);
        sp2 = leaves(i,j+1);
        if sp1 ~= sp2
            adjacent_mat(sp1,sp2) = 1;
            adjacent_mat(sp2,sp1) = 1;
        end
    end
end

for j = 1:size(leaves, 2)   % 沿竖直方向扫描
    for i = 1:size(leaves,1) -1
        sp1 = leaves(i,j);
        sp2 = leaves(i+1,j);
        if sp1 ~= sp2
            adjacent_mat(sp1,sp2) = 1;
            adjacent_mat(sp2,sp1) = 1;
        end
    end
end