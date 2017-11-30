% clear all;close all;home;
all_long_lines = zeros(10,900);
net.lines = zeros(900,100,3);   % 记录每一帧每一个sp属于哪个串
net.bundles = cell(900,100);    % 记录了相似的超像素集合
imgs = dir(fullfile(mcg_root, 'demos1','video1','*.JPEG'));
show.color_line = init_color(512);
show.line_color = zeros(6000,1);
hiers = cell(10,1);
org_imgs = cell(10,1);
% for i = 1:length(imgs)-1
start_frame = 1;
end_frame = 10;
figure;
for i = start_frame:end_frame
    num1=num2str(i,'%06d');
    img_name_1 = [num1,'.JPEG'];
    flow_name = [num1,'.mat'];
    curr_flow = load(fullfile(mcg_root, 'demos1','flow',flow_name));
    curr_flow  = curr_flow.flow;
    I = imread(fullfile(mcg_root, 'demos1','video1',img_name_1));
    show.image = I;
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(mcg_root, 'demos1','hier',hier_name));
    curr_hier  = curr_hier.hier;
    if i == start_frame
        [net,last_hier] = grow_lines(i, net, I, curr_flow, curr_hier);
        last_flow = curr_flow;
    else
        curr_flow2 = load(fullfile(mcg_root, 'demos1','flow2',flow_name));
        curr_flow2  = curr_flow2.flow; 
        [net,last_hier] = grow_lines(i, net, I, curr_flow, curr_hier, curr_flow2, last_hier, last_flow);
        last_flow = curr_flow;
    end
    hiers{i,1} = last_hier;
    org_imgs{i,1} = I;
    if (i-start_frame + 1) > 5
%         show_frame(show, net, hiers{i}, i);
        show_line(net, hiers, 5, i, org_imgs, [100,0,0], 0.5);
    end
    lines = net.lines(:,i,1);
    long_lines = lines(net.lines(:,i,3) == (i-start_frame + 1));
    all_long_lines(i,long_lines) = long_lines;
    X = sprintf('Frame %d finished. %d lines.',i, size(long_lines,1));
    disp(X)
end
% all_long_lines = sparse(all_long_lines);
% spy(all_long_lines);
% show_line(net, show, hiers, 4, 5, org_imgs);



