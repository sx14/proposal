% 输入：当前帧数，现有的所有条；当前帧的hier；光流；上一帧的hier,光流
% 返回：将当前帧连起来以后的所有条
function [net,new_hier] = grow_lines(frame, net, new_frame, new_flow, new_hier, last_hier, last_flow)
if nargin > 5   % 不是第一帧
    % ===== 前一帧的超像素组合矩阵（像素个数） =====
    last_sp_pixel_mat = tabulate(last_hier.leaves_part(:));
    last_sp_pixel_mat = last_sp_pixel_mat(:,1:2);
    last_conbine_mat = get_conbine_mat(last_hier,last_sp_pixel_mat);
    % ===== 使用光流计算两帧底层超像素匹配矩阵（比例）  =====
    match_basic_sp = get_match(last_flow,last_hier.leaves_part,last_sp_pixel_mat,new_hier.leaves_part);
    % ===== 当前帧的超像素组合矩阵（0/1）=====
    new_sp_pixel_mat = tabulate(new_hier.leaves_part(:));
    new_sp_pixel_mat = new_sp_pixel_mat(:,1:2);
    new_conbine_mat = get_conbine_mat(new_hier,new_sp_pixel_mat);
    new_conbine_mat_b = new_conbine_mat | new_conbine_mat;  % 超像素组合矩阵转为01矩阵
    % ===== 上述三个矩阵相乘：各层超像素映射矩阵（像素个数）=====
    match_sp = last_conbine_mat * match_basic_sp * new_conbine_mat_b';
    % ===== 计算交并比 =====
    last_sp_pixels = sum(last_conbine_mat,2);
    new_sp_pixels = sum(new_conbine_mat,2);
    match_sp_iou = cal_IOU(last_sp_pixels, new_sp_pixels, match_sp);
    % ===== 将新一帧匹配的超像素连进串里 =====
    net = grow_curr_frame(net, match_sp_iou, frame);
else    % 是第一帧
    % 将第一帧的所有超像素全部加入lines
    all_level_sp_num = max(max(new_hier.ms_matrix));
    net.lines(1:all_level_sp_num,1,1) = 1:all_level_sp_num; % 初始化第一帧的串号
    net.lines(1:all_level_sp_num,1,2) = 1;  % 初始化第一帧sp的匹配IOU为1
    net.lines(1:all_level_sp_num,1,3) = 1;  % 初始化第一帧的串的长度为1
    for i = 1:all_level_sp_num
        net.bundles{i,1} = i;
    end
end


function net = grow_curr_frame(net, match_sp_iou, frame)
threshold = 0.45;
lines = net.lines;
bundles = net.bundles;
match_sp_iou(match_sp_iou < threshold) = 0;
next_line_index = max(max(lines(:,:,1)))+1;    % 新一个串的编号
% 遍历匹配矩阵的每一行（即前一帧的每一个sp与当前帧所有sp的iou）
for i = 1:size(match_sp_iou,1)
    match_org_sp_i = match_sp_iou(i,:);
%     all_index = find(match_org_sp_i > 0);       % 当前帧所有超过阈值的sp的index
    [max_iou, max_index] = max(match_org_sp_i); % iou最大的sp
    % 当前帧第max_index个sp已经连入某一条，说明前一帧的两个sp很相似，将它们绑定起来
    if max_iou > 0 && abs(max_iou - lines(max_index,frame,2)) < 0.1        
       org_sp_index = find(lines(:,frame-1) == lines(max_index,frame,1));
       bundle1 = bundles{org_sp_index,frame-1};
       bundle2 = bundles{i,frame-1};
       similar_sps = unique([bundle1(:);bundle2(:)]);
       bundles{org_sp_index,frame-1} = similar_sps;
       bundles{i,frame-1} = similar_sps;
    end
    if max_iou > lines(max_index,frame,2)                   % 找到匹配的sp并替换
        lines(max_index,frame,1) = lines(i,frame-1,1);      % 标上匹配的串号
        lines(max_index,frame,2) = max_iou;                 % 标上与第frame帧，第max_index个sp的iou
        lines(max_index,frame,3) = lines(i,frame-1,3)+1;    % 标上串当前的长度
%         all_index = [all_index(:);bundles{max_index,frame}(:)];   % 将所有前一帧可以与当前帧当前sp连的sp记录下来
        bundles{max_index,frame} = max_index;               % 将所有可以连的当前帧sp记录下来
    end
end
% 加入新一帧中未成功匹配的超像素
for j = 1:size(match_sp_iou,2)  
    % 当前帧没有被前一帧匹配的超像素则开一个新的超像素串
    if lines(j,frame,1) == 0
        lines(j,frame,1) = next_line_index;
        lines(j,frame,2) = 1;
        lines(j,frame,3) = 1;
        next_line_index = next_line_index + 1;
        bundles{j,frame} = j;
    end
end
net.lines = lines;
net.bundles = bundles;
