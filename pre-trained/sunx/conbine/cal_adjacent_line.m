function adjacent_line_mat = cal_adjacent_line(lines, adjacent_sp_mat, adjacent_line_mat)
for i = 1:size(adjacent_sp_mat,1);
    for j = 1: i-1
        adjacent = adjacent_sp_mat(i,j);
        if adjacent == 1
            line1 = lines(i);
            line2 = lines(j);
            adjacent_line_mat(line1, line2) = adjacent_line_mat(line1, line2) + 1;        
        end
    end
end
adjacent_line_mat = adjacent_line_mat + adjacent_line_mat';