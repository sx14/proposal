function proposals = connect_proposals(proposals,connect_proposal_cand_mat,frame_sum,return_num)
    temp = sum(connect_proposal_cand_mat,2);
    proposal_connect_max = length(temp(temp > 0));
    proposal_connect_mat = zeros(proposal_connect_max, frame_sum);
    next_connect_index = 0;
    connect_done = zeros(size(connect_proposal_cand_mat,1),1);
    connect_counter = ones(size(connect_proposal_cand_mat,1),1);
    for i = 1:size(connect_proposal_cand_mat,1)
        [~,second,~] = find(connect_proposal_cand_mat(i,:) > 0);
        if ~isempty(second)  % 创建一个新的连接串， i为起始串
            if connect_done(i) == 0
                next_connect_index = next_connect_index + 1;
                proposal_connect_mat(next_connect_index,connect_counter(i)) = i;
                connect_counter(i) = connect_counter(i) + 1;
                connect_done(i) = 1;
            end
        end
        if ~isempty(second)
            [~,s] = max(connect_proposal_cand_mat(i,:));
            while s ~= 0    % 递归填入被连接的串
                if connect_done(s) == 0
                    proposal_connect_mat(next_connect_index,connect_counter(i)) = s;
                    connect_counter(i) = connect_counter(i) + 1;
                    connect_done(s) = 1;
                end
                [~,t,~] = find(connect_proposal_cand_mat(s,:) > 0);
                if ~isempty(t)  % 找到下一个被连接的串
                    s = t(1);
                else
                    s = 0;
                end
            end
        end
    end
    proposal_connect_mat = proposal_connect_mat(1:next_connect_index,:);
    new_proposals = cell(size(proposal_connect_mat,1),1);
    new_proposal_counter = 0;
    for i = 1:size(proposal_connect_mat,1)
        cand_id = length(proposals) + i;
        proposal_connect = proposal_connect_mat(i,:);
        proposals = proposal_connect(proposal_connect > 0);
        start_frame = frame_sum;
        end_frame = 0;
        boxes = zeros(frame_sum,4);
        score = 0;
        for j = 1:length(proposals)
            proposal = proposals{j};
            curr_s = proposal.start_frame;
            curr_e = proposal.end_frame;
            start_frame = min(start_frame,curr_s);
            end_frame = max(end_frame,curr_e);
            boxes = boxes + proposal.boxes;
            score = max(score,proposal.score);
            proposal.score = 0;
            proposals{j} = proposal;
        end
        new_proposal.cand_id = cand_id;
        new_proposal.start_frame = start_frame;
        new_proposal.end_frame = end_frame;
        new_proposal.boxes = boxes;
        new_proposal.video_dir = proposal.video_dir;
        new_proposal.score = score;
        new_proposal_counter = new_proposal_counter + 1;
        new_proposals{new_proposal_counter} = new_proposal;
    end
    proposals = [proposals,new_proposals];
    all_scores = zeros(length(proposals),1);
    for i = 1:length(proposals)
        all_scores(i) = proposals{i}.score;
    end
    [~,ids] = sort(all_scores,'descend');
    return_num = min(return_num,length(ids));
    proposals = proposals(ids(1:return_num));
end

