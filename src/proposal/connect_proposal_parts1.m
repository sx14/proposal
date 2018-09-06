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
proposals = proposals(1:(next_proposal_pos-1));
mask_generation_packages = mask_generation_packages(1:next_proposal_pos-1);
%% connect next parts of proposals to the existed proposals
% proposals: existed proposals
% curr_part_set: next parts of proposals
% last_2_next_IoU_mat: D1-last-part; D2-curr-part
% last_part_proposal_ids: the proposal ids of the last parts of proposals
% next_proposal_id: the next position for the new proposal
function [proposals, curr_part_proposal_ids, next_proposal_pos] = connect(proposals, curr_part_set, last_2_curr_IoU_mat, last_part_proposal_ids, next_proposal_pos, part_set_id)
curr_part_connected_info = zeros(length(curr_part_set), 3);   % pid, IoU, length
fprintf('curr set id: %d\n', part_set_id);
[IoUs, matched_curr_part_ids] = max(last_2_curr_IoU_mat, [], 2);
for last_part_id = 1:length(matched_curr_part_ids)  % for each proposal in last part, last -> curr
    fprintf('last part id: %d\n', last_part_id);
    matched_curr_part_id = matched_curr_part_ids(last_part_id);
    matched_proposal_id = last_part_proposal_ids(last_part_id);
    if matched_proposal_id == 0
        continue;
    end
    matched_proposal = proposals{matched_proposal_id};
    curr_IoU = IoUs(last_part_id);
    
    if curr_IoU > 0 % allow to connect
        curr_part = curr_part_set{matched_curr_part_id};
        curr_part_length = curr_part.end_frame - curr_part.start_frame + 1;
        curr_part_connected_proposal_id = curr_part_connected_info(matched_curr_part_id, 1);
        connect_flag = 0;
        if curr_part_connected_proposal_id > 0 % already connected, check if change
            connected_proposal = proposals{curr_part_connected_proposal_id};
            connected_proposal_length = connected_proposal.end_frame - connected_proposal.start_frame + 1;
            matched_proposal_length = matched_proposal.end_frame - connected_proposal.start_frame + 1;
            if connected_proposal_length > matched_proposal_length  % change
                connect_flag = 1;
            elseif connected_proposal_length == matched_proposal_length  % change
                if curr_part_length > curr_part_connected_info(matched_curr_part_id, 3)
                    connect_flag = 1;
                elseif curr_part_length == curr_part_connected_info(matched_curr_part_id, 3)
                    if curr_IoU > curr_part_connected_info(matched_curr_part_id, 2)
                        connect_flag = 1;
                    end
                end
            else
                % discard
            end
        else % not connected yet, connect
            connect_flag = 1;          
        end
        if connect_flag > 0
            curr_part_connected_info(matched_curr_part_id, 1) = matched_proposal_id;
            curr_part_connected_info(matched_curr_part_id, 2) = curr_IoU;
            curr_part_connected_info(matched_curr_part_id, 3) = curr_part_length;        
        end
    end
end
for curr_part_id = 1:size(curr_part_connected_info, 1)
    matched_proposal_id = curr_part_connected_info(curr_part_id,1);
    curr_part = curr_part_set{curr_part_id};
    if matched_proposal_id ~= 0    % connect        
        proposal = proposals{matched_proposal_id};
        boxes = proposal.boxes;
        curr_boxes = curr_part.boxes;
        boxes = cat(1, boxes, curr_boxes(2:curr_part.end_frame, :)); % head tail overlapped, remove head of curr part
        proposal.boxes = boxes;
        proposal.end_frame = proposal.end_frame + curr_part.end_frame - 1;
        proposals{matched_proposal_id} = proposal;
    else % new proposal
        if curr_part.start_frame == 1 || curr_part.end_frame == get_proposal_part_length()
            curr_part.start_frame = get_proposal_part_length() * (part_set_id - 1) + curr_part.start_frame;
            curr_part.end_frame = get_proposal_part_length() * (part_set_id - 1) + curr_part.end_frame;
            curr_boxes = curr_part.boxes;
            zero_boxes = zeros(get_proposal_part_length() * (part_set_id - 1), 4);
            curr_boxes = cat(1, zero_boxes, curr_boxes);
            curr_part.boxes = curr_boxes;
            proposals{next_proposal_pos} = curr_part;
            curr_part_connected_info(matched_curr_part_id, 1) = next_proposal_pos;
            next_proposal_pos = next_proposal_pos + 1;
        end
    end
end
curr_part_proposal_ids = curr_part_connected_info(:, 1);

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

