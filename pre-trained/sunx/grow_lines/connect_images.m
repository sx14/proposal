% 将视频各帧的层次式超像素连成串
% net:每一帧中每一个sp属于的串号，ratio，长度
% hier:每一帧的层次结构
% org_imgs:每一帧的图像(resized)
% adjacent_sp_mat:每一帧各层次sp的相邻矩阵
function [net,hiers,org_imgs,adjacent_sp_mats] = connect_images(video_path, resize_dir_name, flow_dir_name, flow2_dir_name, hier_dir_name, img_suffix, show_start_frame)
imgs = dir(fullfile(video_path, resize_dir_name ,['*.',img_suffix]));
show.color_line = init_color(512);
show.line_color = zeros(6000,1);
start_frame = 0;
end_frame = length(imgs) - 1;
frame_sum = end_frame - start_frame + 1;    % 帧数
net = zeros(800,frame_sum,3);               % 记录每一帧每一个sp属于哪个串
hiers = cell(frame_sum,1);                  % 保留所有层次结构
org_imgs = cell(frame_sum,1);               % 保留所有原图
adjacent_sp_mats = cell(frame_sum,1);       % 保留所有超像素相邻关系
for i = start_frame:end_frame
    num1=num2str(i,'%06d');
    img_name_1 = [num1,'.', img_suffix];
    flow_name = [num1,'.mat'];
    I = imread(fullfile(video_path, resize_dir_name, img_name_1));
    show.image = I;
    try
    curr_flow = load(fullfile(video_path, flow_dir_name,flow_name));
    curr_flow  = curr_flow.flow;
    catch 
        curr_flow = zeros(size(I,1),size(I,2),2);
    end
    
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(video_path, hier_dir_name, hier_name));
    curr_hier  = curr_hier.hier;
    if i == start_frame
        [net,last_hier,adjacent_sp_mat,sp_boxes] = grow_lines(i+1, net, curr_hier);
        last_flow = curr_flow;
    else
        curr_flow2 = load(fullfile(video_path, flow2_dir_name, flow_name));
        curr_flow2  = curr_flow2.flow; 
        [net,last_hier,adjacent_sp_mat,sp_boxes] = grow_lines(i+1, net, curr_hier, curr_flow2, last_hier, last_flow);
        last_flow = curr_flow;
    end
    adjacent_sp_mats{i+1,1} = adjacent_sp_mat;
    last_hier.sp_boxes = sp_boxes;
    hiers{i+1,1} = last_hier;
    org_imgs{i+1,1} = I;
    if (i-start_frame+1) >= show_start_frame
        show_line(net, hiers, 10 , i+1, org_imgs, [255,0,0]);
        input('next frame?');
    end
    % ====== 展示相邻帧匹配情况 ， 可以注掉 ===========
    lines = net(:,i+1,1);
    if i < 9
        long_lines = lines(net(:,i+1,3) == (i-start_frame+1));
    else
        long_lines = lines(net(:,i+1,3) >= 10);
    end
    basic_sp_num = double(max(max(last_hier.leaves_part)));
    conbined_sp_num = double(size(last_hier.ms_struct,2));
    all_sp_num = double(basic_sp_num + conbined_sp_num);
    basic_matched = double(size(find(net(1:basic_sp_num,i+1,3) > 1),1));
    conbined_matched = double(size(find(net(basic_sp_num+1:basic_sp_num+conbined_sp_num,i+1,3) > 1),1));
    all_matched = double(basic_matched + conbined_matched);
    output_info = sprintf('Frame %d basic:%.2f%%  conbined:%.2f%%  all:%.2f%%  %d:%d', i , basic_matched/basic_sp_num*100, conbined_matched/conbined_sp_num*100, all_matched/all_sp_num*100, size(long_lines,1), size(unique(long_lines),1));
    disp(output_info);
    % ================================================
end








