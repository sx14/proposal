% 将视频各帧的层次式超像素连成串
% volume:每一帧中每一个sp属于的串号，ratio，长度
% hier:每一帧的层次结构
% org_imgs:每一帧的图像(resized)
% adjacent_sp_mat:每一帧各层次sp的相邻矩阵
function [volume,sp_boxes_set,adjacent_sp_mats,sp_boundary_connectivity_set,sp_flow_sum_set,sp_leaves_set, sp_pixel_num_set] = create_volumes(hier_set, flow_set, flow2_set,resized_imgs)
start_frame = 1;
end_frame = length(hier_set);
frame_sum = end_frame - start_frame + 1;    % 帧数
volume = zeros(1500,frame_sum,3);           % 记录每一帧每一个sp属于哪个串
adjacent_sp_mats = cell(frame_sum,1);       % 保留所有超像素相邻关系
sp_boxes_set = cell(frame_sum,1);
sp_flow_sum_set = cell(frame_sum,1);
sp_leaves_set = cell(frame_sum,1);
sp_pixel_num_set = cell(frame_sum,1);
sp_boundary_connectivity_set = cell(frame_sum,1);
for i = start_frame:end_frame
    if i == 15
        a = 1;
    end
    curr_hier = hier_set{i};
    if i == start_frame
        [volume,combine_mat,sp_leaves_mat] = grow_volumes(i, volume, curr_hier);
    else
        last_flow = flow_set{i-1};
        last_hier = hier_set{i-1};
        curr_flow2 = flow2_set{i};
        [volume,combine_mat,sp_leaves_mat] = grow_volumes(i, volume, curr_hier, curr_flow2, last_hier, last_flow);
    end
    [adjacent_sp_mat, sp_boxes, sp_boundary_connectivity, sp_pixel_num] = cal_adjacent_sp(curr_hier.leaves_part, combine_mat);
    sp_flow_sum = get_sp_flow_sum(curr_hier.leaves_part,flow_set{i},combine_mat);
    adjacent_sp_mats{i} = adjacent_sp_mat;
    sp_boundary_connectivity_set{i} = sp_boundary_connectivity;
    sp_boxes_set{i} = sp_boxes;
    sp_flow_sum_set{i} = [sp_flow_sum,sp_pixel_num];
    sp_leaves_set{i} = sp_leaves_mat;
    sp_pixel_num_set{i} = sp_pixel_num;
%     if (i-start_frame+1) >= 50
%         show_volume(volume, hier_set, 10 , i, resized_imgs, [255,0,0]);
%         input('next frame?');
%     end
% ====== 展示相邻帧匹配情况 ， 可以注掉 ===========
%     volumes = volume(:,i,1);
%     if i < 10
%         long_volumes = volumes(volume(:,i,3) == (i-start_frame+1));
%     else
%         long_volumes = volumes(volume(:,i,3) >= 10);
%     end
%     basic_sp_num = double(max(max(curr_hier.leaves_part)));
%     combined_sp_num = double(size(curr_hier.ms_struct,2));
%     all_sp_num = double(basic_sp_num + combined_sp_num);
%     basic_matched = double(size(find(volume(1:basic_sp_num,i,3) > 1),1));
%     combined_matched = double(size(find(volume(basic_sp_num+1:basic_sp_num+combined_sp_num,i,3) > 1),1));
%     all_matched = double(basic_matched + combined_matched);
%     output_info = sprintf('Frame %d basic:%.2f%%  combined:%.2f%%  all:%.2f%%  %d:%d', i , basic_matched/basic_sp_num*100, combined_matched/combined_sp_num*100, all_matched/all_sp_num*100, size(long_volumes,1), size(unique(long_volumes),1));
%     disp(output_info);
    % ================================================
end






