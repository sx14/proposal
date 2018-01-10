% 获取单个视频的处理结果
function proposals = get_proposals(video_dir, output_path, org_height, org_width, hier_set, flow_set, flow2_set,resized_imgs, re_cal)
proposal_dir = 'proposals';
if ~exist(fullfile(output_path, proposal_dir),'dir')    
    mkdir(fullfile(output_path), proposal_dir); % make proposals dir
end
proposal_path = fullfile(output_path, proposal_dir);
proposal_file_name = [video_dir '.mat'];
if ~exist(fullfile(proposal_path,proposal_file_name),'file') || re_cal == true  % not done
    [net,sp_boxes_set,~,sp_boundary_connectivity_set,~] = create_lines(hier_set, flow_set, flow2_set, resized_imgs);      % grow sp sequences
    [long_line_info,all_line_info,new_line_labels] = long_line_filter(net,sp_boundary_connectivity_set);
    long_line_frame_sp_mat = get_line_frame_sp(net, long_line_info, new_line_labels);
    % 连接断串，要修改：long_line_frame_sp_mat,long_line_info,new_line_labels
    line_connect_cand_mat = get_connect_line_cand2(sp_boxes_set,long_line_frame_sp_mat,long_line_info,resized_imgs);
    [net,all_line_info] = connect_lines(net,all_line_info,long_line_info,long_line_frame_sp_mat,line_connect_cand_mat);
    
    % 连接断串，要修改：long_line_frame_sp_mat,long_line_info,new_line_labels
%     long_line_adjacent_mat = cal_adjacent_line_2(net(:,:,1), long_line_info, adjacent_sp_mats, new_line_labels);
%     [cands,cand_info] = get_cands(long_line_info, long_line_adjacent_mat);     % get candidates by grouping
%     proposals = cands_to_proposals(hier_set,cands,sp_boxes_set,sp_flow_info_set,long_line_frame_sp_mat,cand_info,video_dir,org_height, org_width);
%     proposals = smooth_boxes(proposals);
    save(fullfile(proposal_path, proposal_file_name),'proposals');
else    % done, load proposals
    proposals_file = load(fullfile(proposal_path,proposal_file_name));
    proposals = proposals_file.proposals;
end
