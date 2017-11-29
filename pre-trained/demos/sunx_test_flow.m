clear all;close all;home;
net.lines = zeros(600,100,3);   % 记录每一帧每一个sp属于哪个串
net.bundles = cell(600,100);    % 记录了相似的超像素集合
imgs = dir(fullfile(mcg_root, 'demos','video1','*.jpg'));
show.color_line = init_color(512);
show.line_color = zeros(6000,1);
hiers = cell(10,1);
org_imgs = cell(10,1);
% for i = 1:length(imgs)-1
for i = 1:2
    num1=num2str(i,'%04d');
    num2=num2str(i+1,'%04d');
    img_name_1 = [num1,'.jpg'];
    img_name_2 = [num2,'.jpg'];
%     flow_name = [num1,'.mat'];
    I1 = imread(fullfile(mcg_root, 'demos','video1',img_name_1));
    I2 = imread(fullfile(mcg_root, 'demos','video1',img_name_2));
    show.image = I1;
    if i == 1
        curr_flow  = deepflow2(single(I1),single(I2));
        [net,last_hier] = grow_lines(i, net, I1, curr_flow);
    else
        last_flow = curr_flow;
        curr_flow = deepflow2(single(I1),single(I2));
        [net,last_hier] = grow_lines(i, net, I1, curr_flow, last_hier, last_flow);
    end
    hiers{i,1} = last_hier;
    org_imgs{i,1} = I1;
    X = sprintf('Frame %d finished.',i);
    disp(X)
%     pause = input('continue?');
end
show_line(net, show, hiers, 2, 2, org_imgs);



