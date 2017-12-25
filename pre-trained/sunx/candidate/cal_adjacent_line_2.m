% 计算长串相邻关系，矩阵中1代表相邻，0代表不相邻
% line_labels：每一帧上每一个sp所属的旧的串号
% long_line_info：长串信息，包括label, start_frame, end_frame, length
% adjacent_sp_mats：每一帧上的超像素相邻关系
% new_line_label：用旧的串号可以索引到新的串号
function adjacent_line_mat = cal_adjacent_line_2(line_labels, long_line_info, adjacent_sp_mats, new_line_label)
adjacent_line_mat = zeros(size(long_line_info,1), size(long_line_info,1));
for frame = 1:length(adjacent_sp_mats)
    adjacent_sp_mat = adjacent_sp_mats{frame};  % 单帧上的超像素相邻矩阵
    for sp1 = 1:size(adjacent_sp_mat,1)         % 遍历单帧上的sp相邻矩阵，因为是对称矩阵，遍历一半就够了
        for sp2 = 1:sp1 - 1
            if adjacent_sp_mat(sp1,sp2) == 1    % 找到一个相邻sp对
                line1 = line_labels(sp1,frame,1);
                line2 = line_labels(sp2,frame,1);
                new_line1 = new_line_label(line1);
                new_line2 = new_line_label(line2);
                if new_line1 ~= 0 && new_line2 ~= 0 % 找到的相邻串都是长串
                    adjacent_line_mat(new_line1,new_line2) = 1;
                    adjacent_line_mat(new_line2,new_line1) = 1;
                end
            end
        end
    end
end