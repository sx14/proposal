
% 测试
% 假设：前后帧相同，光流全0
% 预期：前后帧所有超像素全部成功连接，对应颜色相同
clear all;close all;home;
net.lines = zeros(600,100,3);   % 记录每一帧每一个sp属于哪个串
net.bundles = cell(600,100);    % 记录了相似的超像素集合
imgs = dir(fullfile(mcg_root, 'demos','video','*.jpg'));
% for i = 1:length(imgs)-1
for i = 6:7
    num1=num2str(i,'%04d');
    img_name_1 = [num1,'.jpg'];
    I = imread(fullfile(mcg_root, 'demos','video',img_name_1));
    curr_flow = zeros(size(I,1), size(I,2),2);
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(mcg_root, 'demos','hier',hier_name));
    curr_hier  = curr_hier.hier;
    show.image = I;
    show.color_line = init_color(512);
    show.line_color = zeros(6000,1);  
    [net,last_hier] = grow_lines(i, net, I, curr_flow,curr_hier);
    show = show_frame(show, net, last_hier, 1);
    X = sprintf('Frame %d finished.',i);
    disp(X)
    pause = input('continue?');
    close all;
end

