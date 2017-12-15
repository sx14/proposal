function sunx_test_show(video_path, img_suffix, hier)
% 测试
% 假设：前后帧相同，光流全0
% 预期：前后帧所有超像素全部成功连接，对应颜色相同
net.lines = zeros(800,100,3);   % 记录每一帧每一个sp属于哪个串
net.bundles = cell(800,100);    % 记录了相似的超像素集合
net.adjacent_lines = zeros(5000,5000);
imgs = dir(fullfile(video_path,'resized',['*.', img_suffix]));
for i = 1:length(imgs)-1
% for i = 0:20
    num1=num2str(i,'%06d');
    img_name = [num1,['.',img_suffix]];
    I = imread(fullfile(video_path,'resized',img_name));
    curr_flow = zeros(size(I,1), size(I,2),2);
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(video_path,hier,hier_name));
    curr_hier  = curr_hier.hier;
    show.image = I;
    show.color_line = init_color(512);
    show.line_color = zeros(6000,1);  
    [net,last_hier] = grow_lines(i+1, net ,curr_hier);
    show_frame(show, net, curr_hier, i+1);
    X = sprintf('Frame %d finished.',i);
    disp(X)
    input('continue?');
    close all;
end

