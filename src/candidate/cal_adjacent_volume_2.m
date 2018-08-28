% 计算长串相邻关系，矩阵中1代表相邻，0代表不相邻
% volume_labels：每一帧上每一个sp所属的旧的串号
% long_volume_info：长串信息，包括label, start_frame, end_frame, length
% adjacent_sp_mats：每一帧上的超像素相邻关系
% new_volume_label：用旧的串号可以索引到新的串号
function [adjacent_volume_mat, adjacent_ratio_mat] = cal_adjacent_volume_2(volume_labels, long_volume_info, adjacent_sp_mats, new_volume_label)
adjacent_volume_mat = zeros(size(long_volume_info,1), size(long_volume_info,1));
threshold = 0.3;
for frame = 1:length(adjacent_sp_mats)
    adjacent_volume_mat_temp = zeros(size(long_volume_info,1), size(long_volume_info,1));
    adjacent_sp_mat = adjacent_sp_mats{frame};  % 单帧上的超像素相邻矩阵
    for sp1 = 1:size(adjacent_sp_mat,1)         % 遍历单帧上的sp相邻矩阵，因为是对称矩阵，遍历一半就够了
        for sp2 = 1:sp1 - 1
            if adjacent_sp_mat(sp1,sp2) == 1    % 找到一个相邻sp对
                volume1 = volume_labels(sp1,frame,1);
                volume2 = volume_labels(sp2,frame,1);
                new_volume1 = new_volume_label(volume1);
                new_volume2 = new_volume_label(volume2);
                if new_volume1 ~= 0 && new_volume2 ~= 0 && new_volume1 ~= new_volume2% 找到的相邻串都是长串
                    adjacent_volume_mat_temp(new_volume1,new_volume2) = 1;
                    adjacent_volume_mat_temp(new_volume2,new_volume1) = 1;
                end
            end
        end
    end
    adjacent_volume_mat_temp = adjacent_volume_mat_temp & adjacent_volume_mat_temp;
    adjacent_volume_mat = adjacent_volume_mat + adjacent_volume_mat_temp;
end
half_volume_adjacent_mat = tril(adjacent_volume_mat);
[volumes1,volumes2,~] = find(half_volume_adjacent_mat > 0);
volume1_info = long_volume_info(volumes1,:);
volume2_info = long_volume_info(volumes2,:);
min_length = min(volume1_info(:,4),volume2_info(:,4));
for i = 1:length(volumes1)
    half_volume_adjacent_mat(volumes1(i),volumes2(i)) = half_volume_adjacent_mat(volumes1(i),volumes2(i)) / min_length(i);
end
adjacent_ratio_mat = half_volume_adjacent_mat + half_volume_adjacent_mat';
half_volume_adjacent_mat(half_volume_adjacent_mat <= threshold) = 0;
adjacent_volume_mat = half_volume_adjacent_mat + half_volume_adjacent_mat';
adjacent_volume_mat = adjacent_volume_mat & adjacent_volume_mat;