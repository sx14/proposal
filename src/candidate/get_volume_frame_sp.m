% 每个串在各帧上的sp
function volume_frame_sp = get_volume_frame_sp(volumes, long_volume_info, volume_label_map)
volume_labels = volumes(:,:,1);
match_ratio_mat = volumes(:,:,2);
volume_frame_sp = zeros(size(long_volume_info,1), size(volume_labels,2),2);
for frame = 1:size(volume_labels,2)   % 遍历每一帧
    for sp = 1:size(volume_labels,1)  % 遍历每一个sp
        volume_label = volume_labels(sp,frame);
        match_ratio = match_ratio_mat(sp,frame);
        if volume_label == 0  % 到头了
            break;
        end
        new_volume_label = volume_label_map(volume_label);
        if new_volume_label ~= 0  % 找到一个长串
            if match_ratio > volume_frame_sp(new_volume_label, frame, 2)    % 匹配相似度更高的sp
                volume_frame_sp(new_volume_label, frame, 1) = sp;
                volume_frame_sp(new_volume_label, frame, 2) = match_ratio;
            end
        end
    end
end
