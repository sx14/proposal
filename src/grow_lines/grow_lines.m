% 输入：当前帧数，现有的所有条；当前帧的hier；光流；上一帧的hier,光流
% 返回：将当前帧连起来以后的所有条
function [net,new_combine_mat] = grow_lines(frame, net, new_hier, new_flow2, last_hier, last_flow)
% ===== 当前帧的超像素组合矩阵（0/1）=====
new_combine_mat = get_combine_mat(new_hier);
if nargin > 3   % 不是第一帧
    % ===== 前一帧的超像素组合矩阵（0/1） =====
    last_combine_mat = get_combine_mat(last_hier);
    % ===== 使用光流计算两帧底层超像素匹配矩阵（像素个数）  =====
    last_2_new_match_basic_sp = get_match(last_flow,last_hier.leaves_part,new_hier.leaves_part);
    % ===== 上述三个矩阵相乘：各层超像素映射矩阵（像素个数）=====
    last_2_new_match_sp = last_combine_mat * last_2_new_match_basic_sp * new_combine_mat';
    % ===== 计算占比 =====
    last_basic_sp_pixel_mat = tabulate(last_hier.leaves_part(:));
    last_basic_sp_pixel_mat = last_basic_sp_pixel_mat(:,2);
    last_sp_pixel_mat = last_combine_mat * last_basic_sp_pixel_mat;     % 前一帧各层次超像素包含的像素个数
    last_2_new_match_sp_ratio = cal_ratio(last_sp_pixel_mat, last_2_new_match_sp);
    % ===== 后一帧向前一帧，重复以上步骤 =====
    new_2_last_match_basic_sp = get_match(new_flow2,new_hier.leaves_part,last_hier.leaves_part);
    new_2_last_match_sp = new_combine_mat * new_2_last_match_basic_sp * last_combine_mat';
    new_basic_sp_pixel_mat = tabulate(new_hier.leaves_part(:));
    new_basic_sp_pixel_mat = new_basic_sp_pixel_mat(:,2);
    new_sp_pixel_mat = new_combine_mat * new_basic_sp_pixel_mat;
    new_2_last_match_sp_ratio = cal_ratio(new_sp_pixel_mat, new_2_last_match_sp);
    % ===== 将新一帧匹配的超像素连进串里 =====
    net = grow_curr_frame(net, last_2_new_match_sp_ratio,new_2_last_match_sp_ratio, frame);
else    % 是第一帧
    % 将第一帧的所有超像素全部加入lines
    all_level_sp_num = new_hier.ms_matrix(end);
    net(1:all_level_sp_num,frame,1) = 1:all_level_sp_num; % 初始化第一帧的串号
    net(1:all_level_sp_num,frame,2) = 1;  % 初始化第一帧sp的匹配IOU为1
    net(1:all_level_sp_num,frame,3) = 1;  % 初始化第一帧的串的长度为1
end


