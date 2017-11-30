function net = grow_curr_frame_cross_or(net, match_sp_iou, back_match_sp_iou,frame)
threshold = 0.4;
lines = net.lines;
bundles = net.bundles;
% 双向and匹配，阈值较低（0.4）
% 正向匹配：遍历last_2_new匹配矩阵的每一行（即前一帧的每一个sp与当前帧所有sp的iou）
match_sp_iou(match_sp_iou < threshold) = 0;
for i = 1:size(match_sp_iou,1)
    match_org_sp_i = match_sp_iou(i,:);
    %     all_index = find(match_org_sp_i > 0);       % 当前帧所有超过阈值的sp的index
    [max_iou, max_index] = max(match_org_sp_i); % iou最大的sp
    % 当前帧第max_index个sp已经连入某一条，说明前一帧的两个sp很相似，将它们绑定起来
    if max_iou > 0 && abs(max_iou - lines(max_index,frame,2)) < 0.1
        org_sp_index = find(lines(:,frame-1) == lines(max_index,frame,1));
        bundle1 = bundles{org_sp_index,frame-1};
        bundle2 = bundles{i,frame-1};
        similar_sps = unique([bundle1(:);bundle2(:)]);
        bundles{org_sp_index,frame-1} = similar_sps;
        bundles{i,frame-1} = similar_sps;
    end
    if max_iou > lines(max_index,frame,2)                   % 找到匹配的sp并替换
        lines(max_index,frame,1) = lines(i,frame-1,1);      % 标上匹配的串号
        lines(max_index,frame,2) = max_iou;                 % 标上与第frame帧，第max_index个sp的iou
        lines(max_index,frame,3) = lines(i,frame-1,3)+1;    % 标上串当前的长度
        %         all_index = [all_index(:);bundles{max_index,frame}(:)];   % 将所有前一帧可以与当前帧当前sp连的sp记录下来
        bundles{max_index,frame} = max_index;               % 将所有可以连的当前帧sp记录下来
    end
end
% 反向匹配：找到所有新一帧中匹配的sp，进行反向匹配确认
back_match_sp_iou(back_match_sp_iou < threshold) = 0;
for j = 1:size(back_match_sp_iou,1)
    match_org_sp = find(back_match_sp_iou(j,:) > 0);
    if lines(j,frame,1) ~= 0  % 新一帧被成功匹配的超像素
        line = lines(j,frame,1);
        last_connected_sp = find(lines(:,frame-1,1) == line);  % 应该只能找到1个   
        if ~ismember(last_connected_sp, match_org_sp)   % 替换
            lines(j,frame,1) = 0;
            lines(j,frame,2) = 0;
            lines(j,frame,3) = 0;
        end
    end
end
% 加入新一帧中未成功匹配的超像素
next_line_index = max(max(lines(:,:,1)))+1;    % 新一个串的编号
for j = 1:size(match_sp_iou,2)
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