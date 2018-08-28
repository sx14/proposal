% 每个串在各帧上的sp
function volume_frame_sp = get_volume_frame_sp(volumes, long_volume_info, volume_label_map, sp_pixel_num_set)
volume_labels = volumes(:,:,1);
match_ratio_mat = volumes(:,:,2);
volume_frame_sp = zeros(size(long_volume_info,1), size(volume_labels,2),2);
% volume_frame_sp1 = zeros(size(long_volume_info,1), size(volume_labels,2),2);
for frame = 1:size(volume_labels,2)   % 遍历每一帧
    sp_pixel_num_mat = sp_pixel_num_set{frame};
    for sp = 1:size(volume_labels,1)  % 遍历每一个sp
        volume_label = volume_labels(sp,frame);
        if volume_label == 0  % 到头了
            break;
        end
        match_ratio = match_ratio_mat(sp,frame);
        sp_pixel_num = sp_pixel_num_mat(sp);
        new_volume_label = volume_label_map(volume_label);
        if new_volume_label ~= 0  % 找到一个长串
            if match_ratio > volume_frame_sp(new_volume_label, frame, 2)    % 匹配相似度更高的sp
                volume_frame_sp(new_volume_label, frame, 1) = sp;
                volume_frame_sp(new_volume_label, frame, 2) = match_ratio;
            end
%             if sp_pixel_num > volume_frame_sp1(new_volume_label, frame, 2)    % 更大的sp
%                 volume_frame_sp1(new_volume_label, frame, 1) = sp;
%                 volume_frame_sp1(new_volume_label, frame, 2) = sp_pixel_num;
%             end
        end
    end
end
