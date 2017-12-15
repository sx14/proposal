function cal_hier_by_slic(video_path, hier_dir_name, resize_dir_name, flow_dir_name, img_suffix, re_cal)
if ~exist(fullfile(video_path, hier_dir_name),'dir')
    mkdir(fullfile(video_path), hier_dir_name);
end
if ~exist(fullfile(video_path, hier_dir_name,'finish'),'file') || re_cal == 1 % cal
    imgs = dir(fullfile(video_path, resize_dir_name, ['*.', img_suffix]));
    default_label_num = 200;
    for i = 0:length(imgs)-1
        num=num2str(i,'%06d');
        img_name = [num,'.', img_suffix];
        flow_name = [num,'.mat'];
        I = imread(fullfile(video_path, resize_dir_name,img_name));
        if i < length(imgs) - 1
            curr_flow = load(fullfile(video_path, flow_dir_name,flow_name));
            curr_flow  = curr_flow.flow;
        else
            curr_flow  = zeros(size(I,1),size(I,2),2);
        end
        
        [leaves_part, label_sum] = slicomex(I,default_label_num);
        leaves_part = leaves_part + 1;  % 从1开始编号
        color_distance = cal_leaf_color_distance(I, leaves_part, label_sum);  % 超像素颜色距离
        flow_distance = cal_leaf_flow_distance(curr_flow, leaves_part, label_sum);  % 超像素颜色距离
        distance = 0.6*color_distance + 0.4*flow_distance;
        %     adjacent_leaves = cal_adjacent_basic_sp(leaves_part);           % 超像素相邻关系
        %     edge = adjacent_leaves .* distance;     % 超像素边缘强度
        %     ucm1 = get_ucm(leaves_part, color_distance);
        %     ucm2 = get_ucm(leaves_part, flow_distance);
        ucm = get_ucm(leaves_part, distance);
        min_edge = min(ucm(ucm > 0));
        temp_leaves_part = leaves_part;
        level = 1;
        conbine_times = label_sum;
        while(conbine_times > 0);
%             figure;
%             imshow(imdilate(ucm,strel(ones(3))),[]), title(['ucm',num2str(level)]);
            test(temp_leaves_part);
            max_edge = max(ucm(ucm > 0));
            min_edge = min(ucm(ucm > 0));
            [ucm,ms_struct_1,temp_leaves_part] = conbine_curr_level(temp_leaves_part,ucm,min_edge+(max_edge - min_edge)/15);
            conbine_times = size(ms_struct_1, 2);
            if level == 1
                ms_struct = ms_struct_1;
            else
                ms_struct = [ms_struct,ms_struct_1];
            end
            level = level + 1;
        end
        hier.leaves_part = leaves_part;
        hier.ms_struct = ms_struct;
        hier_name = [num,'.mat'];
        hier_name = fullfile(video_path, hier_dir_name ,hier_name);
        save(hier_name, 'hier');
        input('wait');
        close all;
    end
    finish(fullfile(video_path, hier_dir_name));
    disp('cal_hier finished.');
else
    disp('cal_hier finished before.');
end