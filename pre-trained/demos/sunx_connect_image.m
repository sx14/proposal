clear all;close all;home;
net.lines = zeros(600,100,3);   % 记录每一帧每一个sp属于哪个串
net.bundles = cell(600,100);    % 记录了相似的超像素集合
imgs = dir(fullfile(mcg_root, 'demos','video','*.jpg'));
show.color_line = init_color(512);
show.line_color = zeros(6000,1);
hiers = cell(10,1);
org_imgs = cell(10,1);
% for i = 1:length(imgs)-1
for i = 1:10
    num1=num2str(i,'%04d');
    img_name_1 = [num1,'.jpg'];
    flow_name = [num1,'.mat'];
    curr_flow = load(fullfile(mcg_root, 'demos','flow',flow_name));
    curr_flow  = curr_flow.flow;
    I = imread(fullfile(mcg_root, 'demos','video',img_name_1));
    show.image = I;
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(mcg_root, 'demos','hier',hier_name));
    curr_hier  = curr_hier.hier;
    if i == 1
        [net,last_hier] = grow_lines(i, net, I, curr_flow, curr_hier);
        last_flow = curr_flow;
    else
        [net,last_hier] = grow_lines(i, net, I, curr_flow, curr_hier,last_hier, last_flow);
        last_flow = curr_flow;
%         show = show_frame(show, net, last_hier, i);
    end
    hiers{i,1} = last_hier;
    org_imgs{i,1} = I;
    if i > 3
        show_line(net, show, hiers, i, i, org_imgs);
    end
    long_lines = find(net.lines(:,i,3) >= (i-1));
    X = sprintf('Frame %d finished. %d lines.',i, size(long_lines,1));
    disp(X)
end
% show_line(net, show, hiers, 4, 5, org_imgs);



