% process one video, obtain proposals
function proposals = get_trajectory_proposals(video_dir, output_path, org_height, org_width, hier_set, flow_set, flow2_set,resized_imgs, re_cal)
    proposal_output_dir = 'proposals';
    if ~exist(fullfile(output_path, proposal_output_dir),'dir')
        mkdir(fullfile(output_path), proposal_output_dir);
    end
    proposal_path = fullfile(output_path, proposal_output_dir);
    proposal_file_name = [video_dir '.mat'];
    if ~exist(fullfile(proposal_path,proposal_file_name),'file') || re_cal == true
        % construct volumes
        [volumes,sp_boxes_set,adjacent_sp_mats,sp_boundary_connectivity_set,sp_flow_info_set] = create_volumes(hier_set, flow_set, flow2_set, resized_imgs);      
        % filter out the extremely short volumes
        [long_volume_info, new_volume_labels] = long_volume_filter(volumes,sp_boundary_connectivity_set);
        % volume id indexes sp id on each frame
        long_volume_frame_sp_mat = get_volume_frame_sp(volumes, long_volume_info, new_volume_labels);
        % get volume pairs which can be connected into one volume
        volume_connect_cand_mat = get_connect_volume_cand2(sp_boxes_set,long_volume_frame_sp_mat,long_volume_info,resized_imgs);
        % connect the broken volumes
        [long_volume_info,long_volume_frame_sp_mat,new_volume_labels] = connect_volumes(long_volume_info,long_volume_frame_sp_mat,volume_connect_cand_mat,new_volume_labels);
        % filter out the short volumes again
        [long_volume_info,new_volume_labels,long_volume_frame_sp_mat] = filter_cand_volume_after_connect(new_volume_labels,long_volume_info,length(hier_set),long_volume_frame_sp_mat);
        % get spatio adjacent volume pairs
        long_volume_adjacent_mat = cal_adjacent_volume(volumes(:,:,1), long_volume_info, adjacent_sp_mats, new_volume_labels);
        % get candidates by grouping
        [cands,cand_info] = get_cands(long_volume_info,long_volume_adjacent_mat);     
        % score and rank
        proposals = cands_to_proposals(hier_set,cands,sp_boxes_set,sp_flow_info_set,long_volume_frame_sp_mat,cand_info,video_dir);
        % resized frame size
        [resized_height,resized_width] = size(hier_set{1}.leaves_part);
        % resize the proposals to the original frame size
        proposals = resize_proposals(proposals,org_height,org_width,resized_height,resized_width);
        save(fullfile(proposal_path, proposal_file_name),'proposals');
    else
        % done, load proposals
        proposals_file = load(fullfile(proposal_path,proposal_file_name));
        proposals = proposals_file.proposals;
    end
end


function [long_volume_info,new_volume_labels,long_volume_frame_sp_mat] = filter_cand_volume_after_connect(new_volume_labels,volume_info,video_length,long_volume_frame_sp_mat)
    long_volume_length_ratio = 0.2;
    min_volume_length = round(video_length * long_volume_length_ratio);
    min_volume_length = min(min_volume_length,20);
    long_volume_info = volume_info(volume_info(:,4) >= min_volume_length,:);
    long_volume_frame_sp_mat = long_volume_frame_sp_mat(volume_info(:,4) >= min_volume_length,:);
    new_volume_labels(:) = 0;
    for i = 1:size(long_volume_info,1)
        new_volume_labels(long_volume_info(i,1)) = i;
    end
end