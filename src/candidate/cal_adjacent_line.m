% 计算长串相邻关系，矩阵中1代表相邻，0代表不相邻
% line_labels：每一帧上每一个sp所属的旧的串号
% long_line_info：长串信息，包括label, start_frame, end_frame, length
% adjacent_sp_mats：每一帧上的超像素相邻关系
% new_line_label：用旧的串号可以索引到新的串号
function adjacent_line_mat = cal_adjacent_line(line_labels, long_line_info, adjacent_sp_mats, new_line_label)
temporal_intersection_ratio_ths = 0.4;  % 时间上相交的帧数占短串的比例
space_temporal_adjacent_ratio_ths = 0.7;             % 空间上相交的帧数/时间上相交的帧数
adjacent_line_mat = zeros(size(long_line_info,1), size(long_line_info,1));  % 统计串在空间上相邻的帧数
for frame = 1:length(adjacent_sp_mats)
    adjacent_line_mat_temp = zeros(size(long_line_info,1), size(long_line_info,1)); % 单帧上的串相邻矩阵（0/1）
    adjacent_sp_mat = adjacent_sp_mats{frame};  % 单帧上的超像素相邻矩阵
    for sp1 = 1:size(adjacent_sp_mat,1)         % 遍历单帧上的sp相邻矩阵，因为是对称矩阵，遍历一半就够了
        for sp2 = 1:sp1 - 1
            if adjacent_sp_mat(sp1,sp2) == 1    % 找到一个相邻sp对
                line1 = line_labels(sp1,frame,1);
                line2 = line_labels(sp2,frame,1);
                new_line1 = new_line_label(line1);
                new_line2 = new_line_label(line2);
                if new_line1 ~= 0 && new_line2 ~= 0 && new_line1 ~= new_line2% 找到的相邻串都是长串
                    adjacent_line_mat_temp(new_line1,new_line2) = 1;
                    adjacent_line_mat_temp(new_line2,new_line1) = 1;
                end
            end
        end
    end
    adjacent_line_mat = adjacent_line_mat + adjacent_line_mat_temp;
end
half_line_adjacent_mat = tril(adjacent_line_mat);   % 对称矩阵取一半
[lines1,lines2,space_adjacent_length] = find(half_line_adjacent_mat);   % 取所有相邻串对
line1_info = long_line_info(lines1,:);
line2_info = long_line_info(lines2,:);
max_start = max(line1_info(:,2),line2_info(:,2));
min_end = min(line1_info(:,3),line2_info(:,3));
temporal_intersection_length = min_end - max_start + 1; % 相邻串在时间上相交的帧数
min_length = min(line1_info(:,4),line2_info(:,4));  % 短串长度
temporal_intersection_ratio = temporal_intersection_length ./ min_length;   % 相邻串在时间上相交的帧数 / 较短串长度
temporal_intersection_ratio(temporal_intersection_ratio < temporal_intersection_ratio_ths) = 0; % 消去小于0.5的
space_temporal_adjacent_ratio = space_adjacent_length ./ temporal_intersection_length;          % 空间上相邻的帧数 / 时间上相交的帧数
space_temporal_adjacent_ratio(space_temporal_adjacent_ratio < space_temporal_adjacent_ratio_ths) = 0;   % 消去小于0.6的
mask = temporal_intersection_ratio & space_temporal_adjacent_ratio; % 满足条件的可组合串对mask
half_line_adjacent_mat(:) = 0;
for i = 1:length(lines1)
    half_line_adjacent_mat(lines1(i),lines2(i)) = mask(i);
end
adjacent_line_mat = half_line_adjacent_mat + half_line_adjacent_mat';