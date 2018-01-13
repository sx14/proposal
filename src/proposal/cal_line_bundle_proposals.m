function proposals = cal_line_bundle_proposals(hier_set,sp_frame_line,all_line_info)
proposal_max = 1000;
frame_sum = length(hier_set);
operate_pool = zeros(proposal_max,frame_sum,20);
operate_cand_scores = zeros(proposal_max,1);
operate_cand_info = zeros(proposal_max,2); % start_frame,end_frame
operate_cand_boxes = zeros(proposal_max,frame_sum,4);
finish_pool = zeros(proposal_max,frame_sum,20);
finish_cand_scores = zeros(proposal_max+1,1);
finish_cand_info = zeros(proposal_max,2);  % start_frame,end_frame
finish_cand_boxes = zeros(proposal_max,frame_sum,4);
finish_cand_counter = 0;
for f = 1:frame_sum     % each frame
    disp(f);
    hier = hier_set{f};
    img_pros = hier.cands;
    operate_hit_length = zeros(proposal_max,1);
    operate_hit_img_pro_id = zeros(proposal_max,1);
    if f == 1                       % initiate operate pool
        for i = 1:size(img_pros,1)  % each image proposal
            img_pro_sps = img_pros(i,:);
            img_pro_sps = img_pro_sps(img_pro_sps > 0);
            line_cand = img_pro_2_line_cand(img_pro_sps',sp_frame_line,f);    % img_pro sp -> lines
            line_cand = line_cand(line_cand > 0);
            operate_pool(i,1,1:length(line_cand)) = line_cand;
            operate_cand_scores(i) = operate_cand_scores(i) + hier.scores(i);
            operate_cand_info(i,:) = 1;     % start=1,end=1
            operate_cand_boxes(i,f,:) = hier.boxes(i,:);
            operate_hit_img_pro_id(i) = i;
        end
    else
        for c = 1:length(operate_pool)  % each line combine cand
            last_cand = operate_pool(c,f-1,:);
            last_cand = last_cand(last_cand > 0);
            predict_cand = predict_line_cand(last_cand,all_line_info,f);
            predict_cand = predict_cand(predict_cand > 0);
            hit_cand = 0;
            for i = 1:size(img_pros,1)  % each image proposal, try to hit existed cand
                img_pro_sps = img_pros(i,:);
                img_pro_sps = img_pro_sps(img_pro_sps > 0);
                line_cand = img_pro_2_line_cand(img_pro_sps',sp_frame_line,f);
                line_cand = line_cand(line_cand > 0);
                hit_lines = intersect(predict_cand,line_cand);
                if ~isempty(hit_lines)  % hit
                    hit_cand = 1;
                    if operate_hit_length(c) == 0 || length(hit_lines) > operate_hit_length(c) % didn't hit before
                        operate_pool(c,f,:) = 0;
                        operate_pool(c,f,1:length(line_cand)) = line_cand;
                        operate_hit_length(c) = length(hit_lines);
                        operate_cand_info(c,2) = f;                     % update end_frame
                        operate_cand_boxes(c,f,:) = hier.boxes(i,:);    % record curr box
                        operate_hit_img_pro_id(c) = i;
                    end
                end
            end
            if hit_cand == 0    % operate cand c didn't hit, move to finish pool
                if finish_cand_counter <= 1000  % rank 1001 cands
                    finish_cand_counter = finish_cand_counter + 1;
                end
                if finish_cand_counter > 1000
                    [~,curr_rank] = sort(finish_cand_scores);
                    finish_pool_next_index = curr_rank(end);
                else
                    finish_pool_next_index = finish_cand_counter;
                end
                avg_scores = operate_cand_scores(c) / (operate_cand_info(c,2) - operate_cand_info(c,1) + 1);
                finish_cand_scores(finish_cand_counter) = avg_scores;
                finish_pool(finish_pool_next_index,:,:) = operate_pool(c,:,:);
                finish_cand_info(finish_pool_next_index,:) = operate_cand_info(c,:);
                finish_cand_boxes(finish_pool_next_index,:,:) = operate_cand_boxes(c,:,:);
                operate_pool(c,:,:) = 0;
                operate_cand_info(c,:) = 0;
                operate_cand_boxes(c,:,:) = 0;
                operate_cand_scores(c) = 0;
            end
        end
    end
end
% TODO:put all operating cand into finish pool

[~,finish_pool_rank] = sort(finish_cand_scores);
proposals = pool2proposals(finish_pool(finish_pool_rank));
end

function proposals = pool2proposals(finish_pool)
    
end

function line_cand = img_pro_2_line_cand(img_cand,sp_frame_line,frame)
line_cand = sp_frame_line(img_cand,frame);
end

function predict_line_cand = predict_line_cand(curr_line_cand, line_info, predict_frame)
curr_line_cand_info = line_info(curr_line_cand,:);
start_frame = curr_line_cand_info(:,2);
end_frame = curr_line_cand_info(:,3);
start_mask = start_frame <= predict_frame;
end_mask = end_frame >= predict_frame;
mask = start_mask & end_mask;
predict_line_cand = curr_line_cand_info(mask,1);
end
