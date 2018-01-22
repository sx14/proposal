% 每个串在各帧上的sp
function line_frame_sp = get_line_frame_sp(lines, long_line_info, line_label_map)
line_labels = lines(:,:,1);
match_ratio_mat = lines(:,:,2);
line_frame_sp = zeros(size(long_line_info,1), size(line_labels,2),2);
for frame = 1:size(line_labels,2)   % 遍历每一帧
    for sp = 1:size(line_labels,1)  % 遍历每一个sp
        line_label = line_labels(sp,frame);
        match_ratio = match_ratio_mat(sp,frame);
        if line_label == 0  % 到头了
            break;
        end
        new_line_label = line_label_map(line_label);
        if new_line_label ~= 0  % 找到一个长串
            if match_ratio > line_frame_sp(new_line_label, frame, 2)    % 匹配相似度更高的sp
                line_frame_sp(new_line_label, frame, 1) = sp;
                line_frame_sp(new_line_label, frame, 2) = match_ratio;
            end
        end
    end
end
line_frame_sp = line_frame_sp(:,:,1);