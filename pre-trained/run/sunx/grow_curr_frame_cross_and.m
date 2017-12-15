function net = grow_curr_frame_cross_and(net, forward_match_sp_ratio, backward_match_sp_ratio,frame)
threshold = 0.5;
lines = net.lines;
bundles = net.bundles;
% 正向匹配：遍历last_2_new匹配矩阵的每一行（即前一帧的每一个sp与当前帧所有sp的avg_ratio）
forward_match_sp_ratio(forward_match_sp_ratio < threshold) = 0;
forward_match = forward_match_sp_ratio | forward_match_sp_ratio;
backward_match_sp_ratio(backward_match_sp_ratio < threshold) = 0;
backward_match = backward_match_sp_ratio | backward_match_sp_ratio;
match = forward_match & backward_match';
forward_match_sp_ratio(~match) = 0;
backward_match_sp_ratio((~match)') = 0;
match_ratio = (forward_match_sp_ratio + backward_match_sp_ratio')/2;
% =====================OK=======================
for i = 1:size(match_ratio,1)   % 正向匹配一遍
    [max_ratio, max_index] = max(match_ratio(i,:));
    if max_ratio > lines(max_index,frame,2)                     % 找到匹配的sp并替换
        lines(max_index,frame,1) = lines(i,frame-1,1);          % 标上匹配的串号
        lines(max_index,frame,2) = max_ratio;                   % 标上与第frame帧，第max_index个sp的iou
        lines(max_index,frame,3) = lines(i,frame-1,3)+1;        % 标上串当前的长度
    end
end

for i = 1:size(match_ratio,2)   % 反向再来一遍
    if lines(i,frame,1) == 0
        [max_ratio, max_index] = max(match_ratio(:,i));
        if max_ratio > 0
            line = lines(max_index,frame-1,1);
            [sp,~,v] = find(lines(:,frame,1) == line);
            if isempty(sp)
                lines(i,frame,1) = line;
                lines(i,frame,2) = max_ratio;
                lines(i,frame,3) = lines(max_index,frame-1,3) + 1;
            else
                if max_ratio > v
                    lines(sp,frame,1) = 0;
                    lines(sp,frame,2) = 0;
                    lines(sp,frame,3) = 0;
                    lines(i,frame,1) = line;
                    lines(i,frame,2) = max_ratio;
                    lines(i,frame,3) = lines(line,frame-1,3) + 1;
                end
            end
        end
    end
end
% 加入新一帧中未成功匹配的超像素
next_line_index = max(max(lines(:,:,1)))+1;    % 新一个串的编号
for j = 1:size(match_ratio,2)
    % 当前帧没有被前一帧匹配的超像素则开一个新的超像素串
    if lines(j,frame,1) == 0
        lines(j,frame,1) = next_line_index;
        lines(j,frame,2) = 1;
        lines(j,frame,3) = 1;
        next_line_index = next_line_index + 1;
        bundles{j,frame} = j;
    end
end
net.lines = lines;
net.bundles = bundles;