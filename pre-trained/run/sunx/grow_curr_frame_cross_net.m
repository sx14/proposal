function net = grow_curr_frame_cross_net(net, forward_match_sp_ratio, backward_match_sp_ratio,frame)
threshold = 0.5;
lines = net.lines;
bundles = net.bundles;
% 正向匹配：遍历last_2_new匹配矩阵的每一行（即前一帧的每一个sp与当前帧所有sp的avg_ratio）
f1 = forward_match_sp_ratio;
b1 = backward_match_sp_ratio;
forward_match_sp_ratio(forward_match_sp_ratio < threshold) = 0;
forward_match = forward_match_sp_ratio | forward_match_sp_ratio;
backward_match_sp_ratio(backward_match_sp_ratio < threshold) = 0;
backward_match = backward_match_sp_ratio | backward_match_sp_ratio;
match = forward_match & backward_match';
forward_match_sp_ratio(~match) = 0;
backward_match_sp_ratio((~match)') = 0;
match_ratio = (forward_match_sp_ratio + backward_match_sp_ratio')/2;
% =====================OK=======================
for i = 1:size(match_ratio,1)
    [~,cand_sp,~] = find(match(i,:) == 1);  % 候选
    mask = zeros(size(lines(:,frame,1)));
    mask(cand_sp',1) = 1;
    mask = lines(:,frame,3) .* mask;
    [matched_cand_indexes,~,~] = find(mask ~= 0);                   % 已经被匹配的sp
    unmatched_cand_indexs = setdiff(cand_sp',matched_cand_indexes); % 未被匹配的sp
    if size(matched_cand_indexes,1) ~= 0                            % 存在已经被匹配过的sp
        if size(unmatched_cand_indexs,1) == 0   % 被长串同化
            temp_length = lines(i,frame-1,3);   % 前一帧即将被匹配的sp
            matched_length = max(lines(matched_cand_indexes,frame ,3)) - 1; % 已经被匹配的sp的前驱在前一帧，前驱的长度
            if temp_length == 1                 % 前一帧即将被匹配的sp长度为1 
                matched = zeros(size(match_ratio(i,:)));
                matched(matched_cand_indexes) = 1;
                matched = matched .* match_ratio(i,:);
                [max_ratio,max_index] = max(matched);
                lines(i,frame-1,1) = lines(max_index,frame,1);
                lines(i,frame-1,2) = lines(max_index,frame,3) - 1;
                lines(i,frame-1,3) = 1;
                % 更新匹配ratio为更大的
                temp = [match_ratio(i,matched_cand_indexes)';lines(matched_cand_indexes,frame,2)];
                temp = max(temp);
                lines(matched_cand_indexes,frame,2) = temp;
            elseif matched_length == 1  % 断开刚刚连接过一次的短串，加入到unmatched中等待被当前串连接                
                lines(matched_cand_indexes,frame,1) = 0;
                lines(matched_cand_indexes,frame,2) = 0;
                lines(matched_cand_indexes,frame,3) = 0;
                unmatched_cand_indexs = matched_cand_indexes;
            end
        else    % 抢
            for j = 1:size(matched_cand_indexes,1)
                if match_ratio(i,matched_cand_indexes(j)) > lines(matched_cand_indexes(j),frame,2)
                    lines(matched_cand_indexes(j),frame,1) = lines(i,frame-1,1);
                    lines(matched_cand_indexes(j),frame,2) = match_ratio(i,matched_cand_indexes(j));
                    lines(matched_cand_indexes(j),frame,3) = lines(i,frame-1,3)+1;
                end
            end
        end
    end
    
    if size(unmatched_cand_indexs,1) ~= 0
        lines(unmatched_cand_indexs',frame,1) = lines(i,frame-1,1);
        lines(unmatched_cand_indexs',frame,2) = match_ratio(i,unmatched_cand_indexs');
        lines(unmatched_cand_indexs',frame,3) = lines(i,frame-1,3)+1;
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