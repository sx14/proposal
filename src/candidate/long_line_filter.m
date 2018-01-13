function [new_line_labels,long_line_info,min_line_length] = long_line_filter(all_line_info,video_length)
    long_line_length_ratio = 0.1;
    min_line_length = round(video_length * long_line_length_ratio);
    min_line_length = min(min_line_length,10);
    long_line_info = all_line_info(all_line_info(:,4) >= min_line_length,:);
    % 串号映射串在all_line_info中的index，相当于给每一个串设置了一个新的连续的id
    new_line_labels = zeros(size(all_line_info,1),1);           
    for i = 1:size(long_line_info,1)
        new_line_labels(long_line_info(i,1)) = i;
    end
end

