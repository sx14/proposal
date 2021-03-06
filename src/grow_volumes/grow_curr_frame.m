function volumes = grow_curr_frame(volumes, forward_match_sp_ratio, backward_match_sp_ratio,frame)
threshold = 0.5;
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
for i = 1:size(match_ratio,1)
    [max_ratio, ~] = max(match_ratio(i,:));
    if max_ratio == 0
        continue;
    end
    [~,cand_sp,~] = find(match_ratio(i,:) >= (max_ratio - 0.1));  % 候选
    mask = zeros(size(volumes(:,frame,1)));
    mask(cand_sp',1) = 1;   % 标识所有候选的匹配sp
    mask = volumes(:,frame,3) .* mask;    % 标识候选的sp中已经被匹配过的sp
    [matched_cand_indexes,~,~] = find(mask ~= 0);                   % 已经被匹配的sp
    unmatched_cand_indexs = setdiff(cand_sp',matched_cand_indexes); % 未被匹配的sp
    if size(matched_cand_indexes,1) ~= 0                            % 存在已经被匹配过的sp
        for j = 1:size(matched_cand_indexes,1)  % 遍历每一个matched sp
            curr_length = volumes(i,frame-1,3);   % frame-1第i个串的长度
            matched_length = volumes(matched_cand_indexes(j),frame,3) - 1;    % matched sp的串长度 - 1，即对应到第frame-1帧的长度
            if curr_length > matched_length     % frame-1第i个串更长，直接抢过来
                volumes(matched_cand_indexes(j),frame,1) = volumes(i,frame-1,1);
                % 填匹配ratio时，考虑前后帧的ratio，这里填的是二者的平均值
                volumes(matched_cand_indexes(j),frame,2) = (match_ratio(i,matched_cand_indexes(j)) + volumes(i,frame-1,2))/2;
                volumes(matched_cand_indexes(j),frame,3) = volumes(i,frame-1,3)+1;
            elseif curr_length == matched_length    % 如果两个串一样长，则开始抢；注意，可能是同一个串，也可能不是
                if (match_ratio(i,matched_cand_indexes(j)) + volumes(i,frame-1,2))/2 > volumes(matched_cand_indexes(j),frame,2)
                    volumes(matched_cand_indexes(j),frame,1) = volumes(i,frame-1,1);
                    volumes(matched_cand_indexes(j),frame,2) = (match_ratio(i,matched_cand_indexes(j)) + volumes(i,frame-1,2))/2;
                    volumes(matched_cand_indexes(j),frame,3) = volumes(i,frame-1,3)+1;
                end
            end
        end
    end
    if size(unmatched_cand_indexs,1) ~= 0   % 没有被匹配过的直接连起来
        volumes(unmatched_cand_indexs',frame,1) = volumes(i,frame-1,1);
        volumes(unmatched_cand_indexs',frame,2) = (match_ratio(i,unmatched_cand_indexs') + volumes(i,frame-1,2)) / 2;
        volumes(unmatched_cand_indexs',frame,3) = volumes(i,frame-1,3)+1;
    end
end

if frame > 1
    last_frame_volumes = volumes(:,frame-1,:);
    [sps,~,~] = find(last_frame_volumes(:,:,2) == 0);
    volumes(sps,frame-1,:) = 0;
end


% 加入新一帧中未成功匹配的超像素
next_line_index = max(max(volumes(:,:,1)))+1;    % 新一个串的编号
for j = 1:size(match_ratio,2)
    % 当前帧没有被前一帧匹配的超像素则开一个新的超像素串
    if volumes(j,frame,1) == 0
        volumes(j,frame,1) = next_line_index;
        volumes(j,frame,2) = 1;
        volumes(j,frame,3) = 1;
        next_line_index = next_line_index + 1;
    end
end