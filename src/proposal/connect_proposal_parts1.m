function [proposals, mask_generation_packages, long_volume_frame_sp_mat] = connect_proposal_parts1(proposal_part_set, mask_generation_packages)
proposal_sum = 0;
IoU_threshold = 0.7;
for i = 1:length(proposal_part_set)
    proposal_sum = proposal_sum + length(proposal_part_set{i});
end
proposals = cell(proposal_sum, 1);
mask_generation_packages = cell(proposal_sum, 1);   % ignore now
long_volume_frame_sp_mat = []; % ignore now
% process the first part set
part_set1 = proposal_part_set{1};
next_proposal_pos = 1;
last_part_proposal_ids = zeros(length(part_set1), 1);
for p = 1:length(part_set1)
    part = part_set1{p};
    if part.end_frame == size(part.boxes, 1)
        proposals{next_proposal_pos} = part;
        last_part_proposal_ids(p) = next_proposal_pos;
        next_proposal_pos = next_proposal_pos + 1;
    end
end
for i = 1:length(proposal_part_set) - 1
    last_2_next_IoU_mat = cal_IoU_mat(proposal_part_set{i}, proposal_part_set{i+1});
    last_2_next_IoU_mat(last_2_next_IoU_mat < IoU_threshold) = 0;
    [proposals, last_part_proposal_ids, next_proposal_pos] = connect(proposals, proposal_part_set{i+1}, last_2_next_IoU_mat, last_part_proposal_ids, next_proposal_pos, i+1);
end
proposals = proposals(1:next_proposal_pos-1);
mask_generation_packages = mask_generation_packages(1:next_proposal_pos-1);
%% connect next parts of proposals to the existed proposals
% proposals: existed proposals
% curr_part_set: next parts of proposals
% last_2_next_IoU_mat: D1-last-part; D2-curr-part
% last_part_proposal_ids: the proposal ids of the last parts of proposals
% next_proposal_id: the next position for the new proposal
function [proposals, curr_part_proposal_ids, next_proposal_pos] = connect(proposals, curr_part_set, last_2_next_IoU_mat, last_part_proposal_ids, next_proposal_pos, part_set_id)
curr_part_proposal_ids = zeros(length(curr_part_set), 1);
proposal_connected_info = zeros(length(proposals), 3);   % pid, IoU, length
[IoUs, matched_last_part_ids] = max(last_2_next_IoU_mat, [], 1);
for curr_part_id = 1:length(matched_last_part_ids)
    matched_last_part_id = matched_last_part_ids(curr_part_id);
    matched_proposal_id = last_part_proposal_ids(matched_last_part_id);
    IoU = IoUs(curr_part_id);
    curr_part = curr_part_set{curr_part_id};
    curr_length = curr_part.end_frame - curr_part.start_frame + 1;
    if IoU > proposal_connected_info(curr_part_id, 2) % matched
        if curr_length > proposal_connected_info(curr_part_id, 3) % better part, update
            proposal_connected_info(matched_proposal_id,1) = curr_part_id;
            proposal_connected_info(matched_proposal_id,2) = IoU;
            proposal_connected_info(matched_proposal_id,3) = curr_length;
            curr_part_proposal_ids(curr_part_id) = matched_proposal_id;
        else
            curr_part_proposal_ids(curr_part_id) = matched_proposal_id;
            % redundant part, discard
        end
    else % maybe a new proposal
        if curr_part.end_frame == size(curr_part.boxes, 1)    % new proposal
            curr_part.start_frame = (part_set_id - 1) * (get_proposal_part_length() - 1) + 1 + (curr_part.start_frame - 1);
            proposals{next_proposal_pos} = curr_part;
            curr_part_proposal_ids(curr_part_id) = next_proposal_pos;
            next_proposal_pos = next_proposal_pos + 1;
        else
            % has no tail, discard
        end
    end
end
for i = 1:size(proposal_connected_info, 1)
    curr_part_id = proposal_connected_info(i,1);
    if curr_part_id ~= 0    % connect
        curr_part = curr_part_set{curr_part_id};
        proposal = proposals{i};
        boxes = proposal.boxes;
        curr_boxes = curr_part.boxes;
        boxes = cat(1, boxes, curr_boxes(2:curr_part.end_frame, :));
        proposal.boxes = boxes;
        proposal.end_frame = proposal.end_frame + curr_part.end_frame - 1;
        proposals{i} = proposal;
    end
end


function IoU_mat = cal_IoU_mat(proposal_parts1, proposal_parts2)
p1_num = length(proposal_parts1);
p2_num = length(proposal_parts2);
p1_tail_boxes = zeros(p1_num, 4);
p2_head_boxes = zeros(p2_num, 4);
for p = 1:p1_num
     part = proposal_parts1{p};
     part_boxes = part.boxes;
     tail_box = part_boxes(size(part_boxes, 1), :);
     p1_tail_boxes(p, :) = tail_box;
end
for p = 1:p2_num
     part = proposal_parts2{p};
     part_boxes = part.boxes;
     head_box = part_boxes(1, :);
     p2_head_boxes(p, :) = head_box;
end
p1_xmaxs = repmat(p1_tail_boxes(:,1),1,p2_num);
p1_ymaxs = repmat(p1_tail_boxes(:,3),1,p2_num);
p1_xmins = repmat(p1_tail_boxes(:,2),1,p2_num);
p1_ymins = repmat(p1_tail_boxes(:,4),1,p2_num);
p2_xmaxs = repmat(p2_head_boxes(:,1),1,p1_num)';
p2_ymaxs = repmat(p2_head_boxes(:,3),1,p1_num)';
p2_xmins = repmat(p2_head_boxes(:,2),1,p1_num)';
p2_ymins = repmat(p2_head_boxes(:,4),1,p1_num)';
intersect_xmaxs = min(p1_xmaxs, p2_xmaxs);
intersect_xmins = max(p1_xmins, p2_xmins);
intersect_ymaxs = min(p1_ymaxs, p2_ymaxs);
intersect_ymins = max(p1_ymins, p2_ymins);
intersect_width = intersect_xmaxs - intersect_xmins;
intersect_height = intersect_ymaxs - intersect_ymins;
intersect_width_mask = intersect_width > 0;
intersect_height_mask = intersect_height > 0;
intersect_mask = intersect_width_mask & intersect_height_mask;
intersect_width(~intersect_mask) = 0;
intersect_height(~intersect_mask) = 0;
intersect = intersect_width .* intersect_height;
tail_area = (p1_xmaxs - p1_xmins) .* (p1_ymaxs - p1_ymins);
head_area = (p2_xmaxs - p2_xmins) .* (p2_ymaxs - p2_ymins);
IoU_mat = intersect ./ (tail_area + head_area - intersect);
IoU_mat(isnan(IoU_mat)) = 0;

