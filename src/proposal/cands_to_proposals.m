function [proposals, proposal_info] = cands_to_proposals(hiers,cands,sp_boxes_set,sp_flow_info_set,sp_boundary_connectivity_set,line_frame_sp_mat,cand_info,video_dir,org_height, org_width)
all_scores = get_cand_scores(hiers, cands, line_frame_sp_mat,cand_info,sp_flow_info_set,sp_boundary_connectivity_set);
one_two_sum = length(find(cand_info(:,5) < 3));
scores_part1 = all_scores(1:one_two_sum);
scores_part2 = all_scores(one_two_sum+1:end);
[~,ids1] = sort(scores_part1,'descend');
[~,ids2] = sort(scores_part2,'descend');
one_two_cand_top_sum = floor(0.8*one_two_sum);      % 一二组合取前60%
if one_two_cand_top_sum < 200                       % 若前60%不足100个，则取全部
    one_two_cand_top_sum = one_two_sum;
end
one_two_cand_sum = min(one_two_cand_top_sum,300);   % 不多于300
ids1 = ids1(1:one_two_cand_sum);
ids = [ids1;ids2];
last_one = min(size(ids,1),1000);                   % proposal sum
selected_cands = cands(ids(1:last_one),:);          % sort cands
% ======== no score ========
% ids = [ids1;ids2];
% last_one = size(ids,1);
% selected_cands = cands(ids(1:last_one),:);
% ======== no score ========
proposals = cell(last_one,1);
proposal_info = cand_info(ids(1:last_one),:);
resized_leaves_part = hiers{1}.leaves_part;
resized_long_edge = max(size(resized_leaves_part));
org_long_edge = max(org_width,org_height);
resize_ratio = org_long_edge / resized_long_edge;
for i = 1:last_one  % 为每一个proposal提取box
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
        cand_max_x = round(max(all_max_x) * resize_ratio);
        cand_min_x = round(min(all_min_x) * resize_ratio);
        cand_max_y = round(max(all_max_y) * resize_ratio);
        cand_min_y = round(min(all_min_y) * resize_ratio);
        boxes(f,:) = [cand_max_x,cand_min_x,cand_max_y,cand_min_y];
    end
    proposal.cand_id = ids(i);
    proposal.start_frame = start_frame;
    proposal.end_frame = end_frame;
    proposal.boxes = boxes;
    proposal.video = video_dir;
    proposals{i} = proposal;
end