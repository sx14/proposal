% 计算底层超像素相邻关系
% 顺便计算底层超像素的bbox
% adjacent_mat 超像素相邻矩阵 0/1
% basic_sp_boxes 超像素bbox:x_max x_min y_max y_min
function [adjacent_mat, basic_sp_boxes, sp_boundary_pixel_num, sp_pixel_num] = cal_adjacent_basic_sp(leaves)
basic_sp_sum = max(max(leaves));
basic_sp_boxes = zeros(basic_sp_sum,4); % x_max x_min y_max y_min
basic_sp_boxes(:,[2,4]) = +Inf;
adjacent_mat = zeros(basic_sp_sum, basic_sp_sum);
sp_boundary_pixel_num = zeros(basic_sp_sum,1);
sp_pixel_num = zeros(basic_sp_sum,1);
[h,w] = size(leaves);
for i = 1:size(leaves, 1)   % 沿水平方向扫描
    for j = 1:size(leaves,2)
        sp1 = leaves(i,j);
        if j < size(leaves,2)
            sp2 = leaves(i,j+1);
            if sp1 ~= sp2
                adjacent_mat(sp1,sp2) = 1;
                adjacent_mat(sp2,sp1) = 1;
            end
        end
        sp1_x = j;
        sp1_y = i;
        sp_pixel_num(sp1) = sp_pixel_num(sp1) + 1;
        if sp1_x == 1 || sp1_x == w || sp1_y == 1 || sp1_y == h
            sp_boundary_pixel_num(sp1) = sp_boundary_pixel_num(sp1) + 1;
        end
        if sp1_x > basic_sp_boxes(sp1,1)
            basic_sp_boxes(sp1,1) = sp1_x;
        end
        if sp1_x < basic_sp_boxes(sp1,2)
            basic_sp_boxes(sp1,2) = sp1_x;
        end
        if sp1_y > basic_sp_boxes(sp1,3)
            basic_sp_boxes(sp1,3) = sp1_y;
        end
        if sp1_y < basic_sp_boxes(sp1,4)
            basic_sp_boxes(sp1,4) = sp1_y;
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