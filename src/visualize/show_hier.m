function show_hier(video_package_path,mid_result_path,video_dir)
% 测试
% 假设：前后帧相同，光流全0
% 预期：前后帧所有超像素全部成功连接，对应颜色相同
[~, ~, resized_imgs] = resize_img(video_package_path,video_dir,mid_result_path,0);
flow_set = cal_flow(video_package_path,video_dir,mid_result_path,resized_imgs,0);
hier_set = cal_hier(video_package_path,video_dir,mid_result_path,flow_set,resized_imgs, false);
frame_sum = length(hier_set);
net = zeros(800,frame_sum,3); 
for i = 1:2
    I = resized_imgs{i};
    curr_hier  = hier_set{i};
    show.image = I;
    show.color_line = init_color(512);
    show.line_color = zeros(6000,1);  
    [net,~] = grow_lines(i, net ,curr_hier);
    show_frame(show, net, curr_hier, i);
    X = sprintf('Frame %d finished.',i-1);
    disp(X)
    input('continue?');
    close all;
end

