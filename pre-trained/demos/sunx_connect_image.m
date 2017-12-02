% clear all;close all;home;
all_long_lines = zeros(10,500);
net.lines = zeros(600,100,3);   % 记录每一帧每一个sp属于哪个串
net.bundles = cell(600,100);    % 记录了相似的超像素集合
imgs = dir(fullfile(mcg_root, 'demos','video','*.jpg'));
show.color_line = init_color(512);
show.line_color = zeros(6000,1);
hiers = cell(10,1);
org_imgs = cell(10,1);
start_frame = 1;
end_frame = 19;
for i = start_frame:end_frame
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
    if i == start_frame
        [net,last_hier] = grow_lines(i, net, curr_hier);
        last_flow = curr_flow;
    else
        curr_flow2 = load(fullfile(mcg_root, 'demos','flow2',flow_name));
        curr_flow2  = curr_flow2.flow; 
        [net,last_hier] = grow_lines(i, net, curr_hier, curr_flow2, last_hier, last_flow);
        last_flow = curr_flow;
    end
    hiers{i,1} = last_hier;
    org_imgs{i,1} = I;
%     if (i-start_frame+1) > 5
% %         show_frame(show, net, hiers{i}, i);
%         show_line(net, hiers, i, i, org_imgs, [0,0,0], 0.8);
%     end
    lines = net.lines(:,i,1);
    long_lines = lines(net.lines(:,i,3) == (i-start_frame+1));
    all_long_lines(i,long_lines) = long_lines;
    X = sprintf('Frame %d finished. %d lines.',i, size(long_lines,1));
    disp(X);
end
all_long_lines = sparse(all_long_lines);
% spy(all_long_lines);
% show_line(net, show, hiers, 4, 5, org_imgs);



