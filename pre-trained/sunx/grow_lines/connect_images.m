% 将视频各帧的层次式超像素连成串
% net:每一帧中每一个sp属于的串号，ratio，长度
% hier:每一帧的层次结构
% org_imgs:每一帧的图像(resized)
% adjacent_sp_mat:每一帧各层次sp的相邻矩阵
function [net,hiers,adjacent_sp_mats, sp_boundary_connectivity_set, sp_conbine_set] = connect_images(hier_set, flow_set, flow2_set,resized_imgs)
start_frame = 1;
end_frame = length(hier_set);
frame_sum = end_frame - start_frame + 1;    % 帧数
net = zeros(1500,frame_sum,3);               % 记录每一帧每一个sp属于哪个串
hiers = cell(frame_sum,1);                  % 保留所有层次结构
adjacent_sp_mats = cell(frame_sum,1);       % 保留所有超像素相邻关系
sp_boundary_connectivity_set = cell(frame_sum,1); 
sp_conbine_set = cell(frame_sum,1);
for i = start_frame:end_frame
    curr_hier = hier_set{i};
    if i == start_frame
        [net,adjacent_sp_mat,sp_boxes,sp_boundary_connectivity,conbine_mat] = grow_lines(i, net, curr_hier);
    else
        last_flow = flow_set{i-1};
        last_hier = hier_set{i-1};
        curr_flow2 = flow2_set{i};
        [net,adjacent_sp_mat,sp_boxes,sp_boundary_connectivity,conbine_mat] = grow_lines(i, net, curr_hier, curr_flow2, last_hier, last_flow);
    end
    adjacent_sp_mats{i} = adjacent_sp_mat;
    sp_boundary_connectivity_set{i} = sp_boundary_connectivity;
    curr_hier.sp_boxes = sp_boxes;
    hiers{i} = curr_hier;
    sp_conbine_set{i} = conbine_mat;
%     if (i-start_frame+1) >= 101
%         show_line(net, hiers, i , i, resized_imgs, [255,0,0]);
%         input('next frame?');
%     end
    % ====== 展示相邻帧匹配情况 ， 可以注掉 ===========
%     lines = net(:,i,1);
%     if i < 10
%         long_lines = lines(net(:,i,3) == (i-start_frame+1));
%     else
%         long_lines = lines(net(:,i,3) >= 10);
%     end
%     basic_sp_num = double(max(max(curr_hier.leaves_part)));
%     conbined_sp_num = double(size(curr_hier.ms_struct,2));
%     all_sp_num = double(basic_sp_num + conbined_sp_num);
%     basic_matched = double(size(find(net(1:basic_sp_num,i,3) > 1),1));
%     conbined_matched = double(size(find(net(basic_sp_num+1:basic_sp_num+conbined_sp_num,i,3) > 1),1));
%     all_matched = double(basic_matched + conbined_matched);
%     output_info = sprintf('Frame %d basic:%.2f%%  conbined:%.2f%%  all:%.2f%%  %d:%d', i , basic_matched/basic_sp_num*100, conbined_matched/conbined_sp_num*100, all_matched/all_sp_num*100, size(long_lines,1), size(unique(long_lines),1));
%     disp(output_info);
    % ================================================
end








