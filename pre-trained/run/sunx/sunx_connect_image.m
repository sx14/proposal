function sunx_connect_image(video_path, resize_dir_name, flow_dir_name, flow2_dir_name, hier_dir_name, img_suffix)
net.lines = zeros(800,100,3);   % 记录每一帧每一个sp属于哪个串
net.adjacent_lines = sparse(50000,50000);
imgs = dir(fullfile(video_path, resize_dir_name ,['*.',img_suffix]));
show.color_line = init_color(512);
show.line_color = zeros(6000,1);
hiers = cell(10,1);
org_imgs = cell(10,1);
start_frame = 0;
end_frame = length(imgs)-2;
if end_frame > 79   % 最多计算80帧
    end_frame = 79;
end
for i = start_frame:end_frame
    num1=num2str(i,'%06d');
    img_name_1 = [num1,'.', img_suffix];
    flow_name = [num1,'.mat'];
    curr_flow = load(fullfile(video_path, flow_dir_name,flow_name));
    curr_flow  = curr_flow.flow;
    I = imread(fullfile(video_path, resize_dir_name, img_name_1));
    show.image = I;
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(video_path, hier_dir_name, hier_name));
    curr_hier  = curr_hier.hier;
    if i == start_frame
        [net,last_hier] = grow_lines(i+1, net, curr_hier);
        last_flow = curr_flow;
    else
        curr_flow2 = load(fullfile(video_path, flow2_dir_name, flow_name));
        curr_flow2  = curr_flow2.flow; 
        [net,last_hier] = grow_lines(i+1, net, curr_hier, curr_flow2, last_hier, last_flow);
        last_flow = curr_flow;
    end
    hiers{i+1,1} = last_hier;
    org_imgs{i+1,1} = I;
%     if (i-start_frame+1) > 55
%         show_line(net, hiers, 10 , i+1, org_imgs, [200,0,0]);
%         input('next frame?');
%     end

    % ====== 展示相邻帧匹配情况 ， 可以注掉 ===========
    lines = net.lines(:,i+1,1);
    if i < 9
        long_lines = lines(net.lines(:,i+1,3) == (i-start_frame+1));
    else
        long_lines = lines(net.lines(:,i+1,3) >= 10);
    end
    basic_sp_num = double(max(max(last_hier.leaves_part)));
    conbined_sp_num = double(size(last_hier.ms_struct,2));
    all_sp_num = double(basic_sp_num + conbined_sp_num);
    basic_matched = double(size(find(net.lines(1:basic_sp_num,i+1,3) > 1),1));
    conbined_matched = double(size(find(net.lines(basic_sp_num+1:basic_sp_num+conbined_sp_num,i+1,3) > 1),1));
    all_matched = double(basic_matched + conbined_matched);
    output_info = sprintf('Frame %d basic:%.2f%%  conbined:%.2f%%  all:%.2f%%  %d:%d', i , basic_matched/basic_sp_num*100, conbined_matched/conbined_sp_num*100, all_matched/all_sp_num*100, size(long_lines,1), size(unique(long_lines),1));
    disp(output_info);
    % ================================================
end
% cal_cands(net.lines(:,:,1), hiers);
cal_bundle_cands(net);






