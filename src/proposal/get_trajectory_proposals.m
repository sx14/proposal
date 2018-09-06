% process one video, obtain proposals
function [proposals,mask_generation_package] = get_trajectory_proposals(video_dir, output_path, org_height, org_width, hier_set, flow_set, flow2_set,resized_imgs, re_cal)
    proposal_output_dir = 'proposals';
    if ~exist(fullfile(output_path, proposal_output_dir),'dir')
        mkdir(fullfile(output_path), proposal_output_dir);
    end
    proposal_path = fullfile(output_path, proposal_output_dir);
    proposal_file_name = [video_dir '.mat'];
    if ~exist(fullfile(proposal_path,proposal_file_name),'file') || re_cal == true
        % start from last end
        frame_sum = length(resized_imgs);
        proposal_part_length = get_proposal_part_length();
        complete_part_num = floor(frame_sum / (proposal_part_length - 1));
        tail_length = mod(frame_sum, (proposal_part_length - 1));
        if tail_length <= floor(proposal_part_length / 2)
            part_num = complete_part_num;
        else
            part_num = complete_part_num + 1; 
        end
        proposal_part_set = cell(part_num, 1);
        mask_generation_package_set = cell(part_num, 1);
        for part = 1:part_num
            start_frame = 1 + (part - 1) * (proposal_part_length - 1);
            end_frame = 1 + (part) * (proposal_part_length - 1);
            if part == part_num
                end_frame = frame_sum;
            end
            resized_imgs_subset = resized_imgs(start_frame:end_frame);
            flow_subset = flow_set(start_frame:end_frame);
            flow2_subset = flow2_set(start_frame:end_frame);
            hier_subset = hier_set(start_frame:end_frame);
            [proposal_parts,mask_generation_package] = get_part_trajectory_proposals(video_dir,hier_subset,flow_subset,flow2_subset,resized_imgs_subset);
            proposal_part_set{part} = proposal_parts;
            mask_generation_package_set{part} = mask_generation_package;
        end
        [proposals, ~, ~] = connect_proposal_parts1(proposal_part_set, mask_generation_package_set);
        
        % resized frame size
        [resized_height,resized_width] = size(hier_set{1}.leaves_part);
        % resize the proposals to the original frame size
        proposals = fill_empty_boxes_at_tail(proposals, frame_sum);
        proposals = resize_proposals(proposals,org_height,org_width,resized_height,resized_width);
        save(fullfile(proposal_path, proposal_file_name),'proposals');
%         mask_generation_package.proposal_volume_group = volume_group;
%         mask_generation_package.hier_set = hier_set;
%         mask_generation_package.volume_frame_sp_mat = long_volume_frame_sp_mat;
%         mask_generation_package.sp_leaves_set = sp_leaves_set;
    else
        % done, load proposals
        proposals_file = load(fullfile(proposal_path,proposal_file_name));
        proposals = proposals_file.proposals;
    end
    mask_generation_package.resized_imgs = resized_imgs;
    mask_generation_package.org_width = org_width;
    mask_generation_package.org_height = org_height;
end

function proposals = fill_empty_boxes_at_tail(proposals, frame_sum)
    for p = 1:length(proposals)
        fprintf('pid: %d\n', p);
        proposal = proposals{p};
        boxes = proposal.boxes;
        if proposal.end_frame < frame_sum
            fill = zeros(frame_sum - proposal.end_frame, 4);
            boxes = cat(1, boxes, fill);
        end
        proposal.boxes = boxes;
        proposals{p} = proposal;
    end
end