function net = grow_curr_frame_cross_and(net, forward_match_sp_ratio, backward_match_sp_ratio,frame)
threshold = 0.5;
lines = net.lines;
bundles = net.bundles;
% 正向匹配：遍历last_2_new匹配矩阵的每一行（即前一帧的每一个sp与当前帧所有sp的iou）
forward_match_sp_ratio(forward_match_sp_ratio < threshold) = 0;
forward_match = forward_match_sp_ratio | forward_match_sp_ratio;
backward_match_sp_ratio(backward_match_sp_ratio < threshold) = 0;
backward_match = backward_match_sp_ratio | backward_match_sp_ratio;
match = forward_match & backward_match';
forward_match_sp_ratio(~match) = 0;
backward_match_sp_ratio((~match)') = 0;
match_ratio = (forward_match_sp_ratio + backward_match_sp_ratio')/2;
for i = 1:size(match_ratio,1)
    match_org_sp_i = match_ratio(i,:);
    [max_ratio, max_index] = max(match_org_sp_i); % iou最大的sp
    % 当前帧第max_index个sp已经连入某一条，说明前一帧的两个sp很相似，将它们绑定起来
    if max_ratio > 0 && abs(max_ratio - lines(max_index,frame,2)) < 0.1
        org_sp_index = find(lines(:,frame-1) == lines(max_index,frame,1));
        bundle1 = bundles{org_sp_index,frame-1};
        bundle2 = bundles{i,frame-1};
        similar_sps = unique([bundle1(:);bundle2(:)]);
        bundles{org_sp_index,frame-1} = similar_sps;
        bundles{i,frame-1} = similar_sps;
    end
    if max_ratio > lines(max_index,frame,2)                   % 找到匹配的sp并替换
        lines(max_index,frame,1) = lines(i,frame-1,1);      % 标上匹配的串号
        lines(max_index,frame,2) = max_ratio;                 % 标上与第frame帧，第max_index个sp的iou
        lines(max_index,frame,3) = lines(i,frame-1,3)+1;    % 标上串当前的长度
        bundles{max_index,frame} = max_index;               % 将所有可以连的当前帧sp记录下来
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