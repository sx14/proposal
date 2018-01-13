% 每个串在各帧上的sp
function line_frame_sp = get_line_frame_sp(lines, all_line_info)
line_labels = lines(:,:,1);
frame_sum = size(line_labels,2);
match_ratio_mat = lines(:,:,2);
line_frame_sp = zeros(size(all_line_info,1),frame_sum ,2);
for frame = 1:size(line_labels,2)   % 遍历每一帧
    for sp = 1:size(line_labels,1)  % 遍历每一个sp
        line_label = line_labels(sp,frame);
        if line_label == 0  % 到头了
            break;
        else
            match_ratio = match_ratio_mat(sp,frame);
            if match_ratio > line_frame_sp(line_label, frame, 2)    % 匹配相似度更高的sp
                line_frame_sp(line_label, frame, 1) = sp;
                line_frame_sp(line_label, frame, 2) = match_ratio;
            end
        end
    end
end
line_frame_sp = line_frame_sp(:,:,1);