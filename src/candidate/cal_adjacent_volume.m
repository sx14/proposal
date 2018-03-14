% 计算长串相邻关系，矩阵中1代表相邻，0代表不相邻
% volume_labels：每一帧上每一个sp所属的旧的串号
% long_volume_info：长串信息，包括label, start_frame, end_frame, length
% adjacent_sp_mats：每一帧上的超像素相邻关系
% new_volume_label：用旧的串号可以索引到新的串号
function adjacent_volume_mat = cal_adjacent_volume(volume_labels, long_volume_info, adjacent_sp_mats, new_volume_label)
temporal_intersection_ratio_ths = 0.4;  % 时间上相交的帧数占短串的比例
space_temporal_adjacent_ratio_ths = 0.7;             % 空间上相交的帧数/时间上相交的帧数
adjacent_volume_mat = zeros(size(long_volume_info,1), size(long_volume_info,1));  % 统计串在空间上相邻的帧数
for frame = 1:length(adjacent_sp_mats)
    adjacent_volume_mat_temp = zeros(size(long_volume_info,1), size(long_volume_info,1)); % 单帧上的串相邻矩阵（0/1）
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
    adjacent_volume_mat = adjacent_volume_mat + adjacent_volume_mat_temp;
end
half_volume_adjacent_mat = tril(adjacent_volume_mat);   % 对称矩阵取一半
[volumes1,volumes2,space_adjacent_length] = find(half_volume_adjacent_mat);   % 取所有相邻串对
volume1_info = long_volume_info(volumes1,:);
volume2_info = long_volume_info(volumes2,:);
max_start = max(volume1_info(:,2),volume2_info(:,2));
min_end = min(volume1_info(:,3),volume2_info(:,3));
temporal_intersection_length = min_end - max_start + 1; % 相邻串在时间上相交的帧数
min_length = min(volume1_info(:,4),volume2_info(:,4));  % 短串长度
temporal_intersection_ratio = temporal_intersection_length ./ min_length;   % 相邻串在时间上相交的帧数 / 较短串长度
temporal_intersection_ratio(temporal_intersection_ratio < temporal_intersection_ratio_ths) = 0; % 消去小于0.5的
space_temporal_adjacent_ratio = space_adjacent_length ./ temporal_intersection_length;          % 空间上相邻的帧数 / 时间上相交的帧数
space_temporal_adjacent_ratio(space_temporal_adjacent_ratio < space_temporal_adjacent_ratio_ths) = 0;   % 消去小于0.6的
mask = temporal_intersection_ratio & space_temporal_adjacent_ratio; % 满足条件的可组合串对mask
half_volume_adjacent_mat(:) = 0;
for i = 1:length(volumes1)
    half_volume_adjacent_mat(volumes1(i),volumes2(i)) = mask(i);
end
adjacent_volume_mat = half_volume_adjacent_mat + half_volume_adjacent_mat';
