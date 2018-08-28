function net = grow_curr_frame2(net, forward_match_sp_ratio, backward_match_sp_ratio,frame)
threshold = 0.5;
volumes = net;
% 匹配：遍历last_2_new匹配矩阵的每一行（即前一帧的每一个sp与当前帧所有sp的avg_ratio）
forward_match_sp_ratio(forward_match_sp_ratio < threshold) = 0;
forward_match = forward_match_sp_ratio | forward_match_sp_ratio;
backward_match_sp_ratio(backward_match_sp_ratio < threshold) = 0;
backward_match = backward_match_sp_ratio | backward_match_sp_ratio;
match = forward_match & backward_match';
forward_match_sp_ratio(~match) = 0;
backward_match_sp_ratio((~match)') = 0;
match_ratio = (forward_match_sp_ratio + backward_match_sp_ratio')/2;
% =====================OK=======================
for i = 1:size(match_ratio,1)   % each sp on last frame
    [max_ratio, ~] = max(match_ratio(i,:));
    if max_ratio == 0
        continue;
    end
    curr_length = volumes(i,frame-1,3);   % frame-1第i个串的长度
    match = match_ratio(i,:);
    match(match < (max_ratio - 0.1)) = 0;   % 误差大的删掉
    [ratio,cand_sp] = sort(match,'descend');
    flag = 0;
    for j = 1:size(cand_sp,2)               % 遍历每一个候选sp
        if ratio(j) == 0
            break;
        end
        matched_length = volumes(cand_sp(j),frame,3) - 1;    % matched sp的串长度 - 1，即对应到第frame-1帧的长度
        if curr_length > matched_length     % frame-1第i个串更长，直接抢过来
            volumes(cand_sp(j),frame,1) = volumes(i,frame-1,1);
            volumes(cand_sp(j),frame,2) = ratio(j);
            volumes(cand_sp(j),frame,3) = curr_length+1;
            flag = 1;
        elseif curr_length == matched_length    % 如果两个串一样长，则开始抢
            if ratio(j) > volumes(cand_sp(j),frame,2)
                volumes(cand_sp(j),frame,1) = volumes(i,frame-1,1);
                volumes(cand_sp(j),frame,2) = ratio(j);
                volumes(cand_sp(j),frame,3) = curr_length+1;
                flag = 1;
            end
        end
        if flag == 1
            break;
        end
    end
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
net = volumes;