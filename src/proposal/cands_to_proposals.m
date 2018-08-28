function [proposals,volume_group] = cands_to_proposals(hiers,cands,sp_boxes_set,sp_flow_info_set,line_frame_sp_mat,cand_info,video_dir)
all_scores = get_cand_scores(hiers, cands, line_frame_sp_mat,cand_info,sp_flow_info_set);
one_two_sum = length(find(cand_info(:,5) < 3));
scores_part1 = all_scores(1:one_two_sum);
scores_part2 = all_scores(one_two_sum+1:end);
scores = [scores_part1;scores_part2];
[~,ids1] = sort(scores_part1,'descend');
[~,ids2] = sort(scores_part2,'descend');
ids2 = ids2 + one_two_sum;
one_two_cand_top_sum = floor(0.8*one_two_sum);      % 一二组合取前80%
one_two_cand_sum = min(one_two_cand_top_sum,300);   % 不多于300
ids1 = ids1(1:one_two_cand_sum);
ids = [ids1;ids2];
last_one = min(length(ids),1000);                   % proposal sum
selected_cands = cands(ids(1:last_one),:);          % sorted cands
selected_cand_scores = scores(ids(1:last_one));
proposals = cell(last_one,1);
proposal_info = cand_info(ids(1:last_one),:);
for i = 1:last_one      % generate boxes for each proposal
    cand_lines = selected_cands(i,:);
    cand_lines = cand_lines(cand_lines > 0);
    start_frame = proposal_info(i,2);
    end_frame = proposal_info(i,3);
    boxes = zeros(length(hiers),4);
    for f = start_frame:end_frame
        cand_sps = line_frame_sp_mat(cand_lines,f);
        cand_sps = cand_sps(cand_sps > 0);
        if isempty(cand_sps)
            continue;
        end
        sp_boxes = sp_boxes_set{f};
        cand_sps_boxes = sp_boxes(cand_sps,:);
        all_max_x = cand_sps_boxes(:,1);
        all_min_x = cand_sps_boxes(:,2);
        all_max_y = cand_sps_boxes(:,3);
        all_min_y = cand_sps_boxes(:,4);
        cand_max_x = max(all_max_x);
        cand_min_x = min(all_min_x);
        cand_max_y = max(all_max_y);
        cand_min_y = min(all_min_y);
        boxes(f,:) = [cand_max_x,cand_min_x,cand_max_y,cand_min_y];
    end
    proposal.cand_id = ids(i);
    proposal.volume_num = cand_info(ids(i),5);
    proposal.start_frame = start_frame;
    proposal.end_frame = end_frame;
    proposal.boxes = boxes;
    proposal.video = video_dir;
    proposal.score = selected_cand_scores(i);
    proposals{i} = proposal;
end
volume_group = selected_cands;
% =========== connect short proposals ============
% proposals_part1 = proposals(1:one_two_sum);
% proposals_part2 = proposals(one_two_sum+1:end);
% proposals_part2_info = proposal_info(one_two_sum+1:end,:);
% connect_proposal_cands = get_connect_proposal_cand(proposals_part2,proposals_part2_info,resized_imgs);
% proposals_part2 = connect_proposals(proposals,connect_proposal_cands,length(hiers),1000-one_two_sum);
% proposals = [proposals_part1,proposals_part2];