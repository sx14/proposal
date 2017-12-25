% 获取单个视频的处理结果
function proposals = get_proposals(video_dir, output_path, org_height, org_width, hier_set, flow_set, flow2_set)
proposal_dir = 'proposals';
if ~exist(fullfile(output_path, proposal_dir),'dir')    
    mkdir(fullfile(output_path), proposal_dir); % make proposals dir
end
proposal_path = fullfile(output_path, proposal_dir);
proposal_file_name = [video_dir '.mat'];
if ~exist(fullfile(proposal_path,proposal_file_name),'file')  % not done
    [net,hiers,adjacent_sp_mats] = connect_images(hier_set, flow_set, flow2_set);      % grow sp sequences
    [long_line_info, new_line_labels] = long_line_filter(net, round(length(hier_set) * 0.2));   % pruning
    [cands,cand_info] = get_cands(net(:,:,1),long_line_info, new_line_labels, adjacent_sp_mats);    % get candidates by grouping
    long_line_frame_sp_mat = get_line_frame_sp(net, long_line_info, new_line_labels);
    proposals = cands_to_proposals(hiers,cands,long_line_frame_sp_mat,cand_info,video_dir,org_height, org_width);
    save(fullfile(proposal_path, proposal_file_name),'proposals');
else    % done, load proposals
    proposals_file = load(fullfile(proposal_path,proposal_file_name));
    proposals = proposals_file.proposals;
end
