% process one video, obtain proposals
function [proposals,mask_generation_package] = get_part_trajectory_proposals(video_dir, hier_set, flow_set, flow2_set,resized_imgs)
% construct volumes
[volumes,sp_boxes_set,adjacent_sp_mats,sp_boundary_connectivity_set,sp_flow_info_set,sp_leaves_set,sp_pixel_num_set] = create_volumes(hier_set, flow_set, flow2_set, resized_imgs);
% filter out the extremely short volumes
[long_volume_info, new_volume_labels] = long_volume_filter(volumes,sp_boundary_connectivity_set);
% volume id indexes sp id on each frame
long_volume_frame_sp_mat = get_volume_frame_sp(volumes, long_volume_info, new_volume_labels, sp_pixel_num_set);
% get spatio adjacent volume pairs
[long_volume_adjacent_mat, adjacent_ratio_mat] = cal_adjacent_volume_2(volumes(:,:,1), long_volume_info, adjacent_sp_mats, new_volume_labels);
% get candidates by grouping
[cands,cand_info] = get_cands(long_volume_info,long_volume_adjacent_mat);
% score and rank
[proposals,volume_group] = cands_to_proposals(hier_set,cands,sp_boxes_set,sp_flow_info_set,long_volume_frame_sp_mat,cand_info,video_dir);
mask_generation_package.proposal_volume_group = volume_group;
mask_generation_package.hier_set = hier_set;
mask_generation_package.volume_frame_sp_mat = long_volume_frame_sp_mat;
mask_generation_package.sp_leaves_set = sp_leaves_set;
mask_generation_package.resized_imgs = resized_imgs;
end