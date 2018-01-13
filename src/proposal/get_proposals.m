% 获取单个视频的处理结果
function proposals = get_proposals(video_dir, output_path, org_height, org_width, hier_set, flow_set, flow2_set,resized_imgs, re_cal)
proposal_dir = 'proposals';
if ~exist(fullfile(output_path, proposal_dir),'dir')    
    mkdir(fullfile(output_path), proposal_dir);
end
proposal_path = fullfile(output_path, proposal_dir);
proposal_file_name = [video_dir '.mat'];
if ~exist(fullfile(proposal_path,proposal_file_name),'file') || re_cal == true
    % create sp lines
    [net,sp_boxes_set,~,sp_boundary_connectivity_set,sp_flow_info_set] = create_lines(hier_set, flow_set, flow2_set, resized_imgs);      % grow sp sequences
    % get all line info
    all_line_info = get_line_info(net(:,:,1),sp_boundary_connectivity_set);
    % abandon so short lines
    [~,long_line_info,min_length] = long_line_filter(all_line_info,size(net,2));
    % get all line -> sp on each frame
    line_frame_sp_mat = get_line_frame_sp(net,all_line_info);
    % get short line -> sp on each frame
    long_line_frame_sp_mat = long_line_frame_sp_filter(line_frame_sp_mat,all_line_info,min_length);
    % short lines to long lines candidates
    line_connect_cand_mat = get_connect_line_cand(sp_boxes_set,long_line_frame_sp_mat,long_line_info,resized_imgs);
    % connect short line candidates
    [net,all_line_info,new_line_frame_sp_mat] = connect_lines(net,all_line_info,long_line_info,long_line_frame_sp_mat,line_connect_cand_mat);
    line_frame_sp_mat = cat(1,line_frame_sp_mat,new_line_frame_sp_mat);
    % img proposals -> line bundle cands
    [line_bundle_cands,all_cand_info] = cal_line_bundle_cands(hier_set,net(:,:,1),all_line_info);
    % sort, get line bundle proposals
    proposals = cands_to_proposals(hier_set,line_bundle_cands,sp_boxes_set,sp_flow_info_set,sp_boundary_connectivity_set,line_frame_sp_mat,all_cand_info,video_dir,org_height, org_width);
%     proposals = smooth_boxes(proposals);
    save(fullfile(proposal_path, proposal_file_name),'proposals');
else    % done, load proposals
    proposals_file = load(fullfile(proposal_path,proposal_file_name));
    proposals = proposals_file.proposals;
end
