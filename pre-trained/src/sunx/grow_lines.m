% 输入：当前帧数，现有的所有条；当前帧的hier；光流；上一帧的hier,光流
% 返回：将当前帧连起来以后的所有条
function [net,new_hier] = grow_lines(frame, net, new_frame, new_flow, new_hier, new_flow2, last_hier, last_flow)
if nargin > 5   % 不是第一帧<<<
    % ===== 前一帧的超像素组合矩阵（像素个数） =====
    last_sp_pixel_mat = tabulate(last_hier.leaves_part(:));
    last_sp_pixel_mat = last_sp_pixel_mat(:,1:2);
    last_conbine_mat = get_conbine_mat(last_hier,last_sp_pixel_mat);
    % ===== 使用光流计算两帧底层超像素匹配矩阵（比例）  =====
    last_2_new_match_basic_sp = get_match(last_flow,last_hier.leaves_part,last_sp_pixel_mat,new_hier.leaves_part);
    % ===== 当前帧的超像素组合矩阵（0/1）=====
    new_sp_pixel_mat = tabulate(new_hier.leaves_part(:));
    new_sp_pixel_mat = new_sp_pixel_mat(:,1:2);
    new_conbine_mat = get_conbine_mat(new_hier,new_sp_pixel_mat);
    new_conbine_mat_b = new_conbine_mat | new_conbine_mat;  % 超像素组合矩阵转为01矩阵
    % ===== 上述三个矩阵相乘：各层超像素映射矩阵（像素个数）=====
    last_2_new_match_sp = last_conbine_mat * last_2_new_match_basic_sp * new_conbine_mat_b';
    % ===== 计算交并比 =====
    last_sp_pixels = sum(last_conbine_mat,2);
    new_sp_pixels = sum(new_conbine_mat,2);
    last_2_new_match_sp_iou = cal_IOU(last_sp_pixels, new_sp_pixels, last_2_new_match_sp);
    % ===== 后一帧向前一帧，重复以上步骤 =====
    last_conbine_mat_b = last_conbine_mat | last_conbine_mat;  % 超像素组合矩阵转为01矩阵
    new_2_last_match_basic_sp = get_match(new_flow2,new_hier.leaves_part,new_sp_pixel_mat,last_hier.leaves_part);
    new_2_last_match_sp = new_conbine_mat * new_2_last_match_basic_sp * last_conbine_mat_b';
    new_2_last_match_sp_iou = cal_IOU(new_sp_pixels, last_sp_pixels, new_2_last_match_sp);
    % ===== 将新一帧匹配的超像素连进串里 =====
%     net = grow_curr_frame(net, last_2_new_match_sp_iou, frame);
%     net = grow_curr_frame_cross_or(net, last_2_new_match_sp_iou,new_2_last_match_sp_iou, frame);
%     net = grow_curr_frame_cross_or(net, last_2_new_match_sp_iou,last_2_new_match_sp_iou', frame);
%     net = grow_curr_frame_cross_and(net, last_2_new_match_sp_iou,new_2_last_match_sp_iou, frame);
    net = grow_curr_frame_cross_or_net(net, last_2_new_match_sp_iou,new_2_last_match_sp_iou, frame);


else    % 是第一帧
    % 将第一帧的所有超像素全部加入lines
    all_level_sp_num = max(max(new_hier.ms_matrix));
    net.lines(1:all_level_sp_num,1,1) = 1:all_level_sp_num; % 初始化第一帧的串号
    net.lines(1:all_level_sp_num,1,2) = 1;  % 初始化第一帧sp的匹配IOU为1
    net.lines(1:all_level_sp_num,1,3) = 1;  % 初始化第一帧的串的长度为1
    for i = 1:all_level_sp_num
        net.bundles{i,1} = i;
    end
end



