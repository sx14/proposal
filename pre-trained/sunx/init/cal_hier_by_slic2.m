function cal_hier_by_slic2(video_path, hier_dir_name, resize_dir_name, flow_dir_name, img_suffix, re_cal)
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
        curr_flow = load(fullfile(video_path, flow_dir_name,flow_name));
        curr_flow  = curr_flow.flow;
        [leaves_part, label_sum] = slicomex(I,default_label_num);
        leaves_part = leaves_part + 1;  % 从1开始编号
        color_distance = cal_leaf_color_distance(I, leaves_part, label_sum);  % 超像素颜色距离
        flow_distance = cal_leaf_flow_distance(curr_flow, leaves_part, label_sum);  % 超像素颜色距离
        distance = 0.6*color_distance + 0.4*flow_distance;
        ucm = get_ucm(leaves_part, distance);
        max_edge = max(max(ucm));
        ucm = ucm / max_edge;
        hier = ucm2hier(ucm,curr_flow);
        hier_name = [num,'.mat'];
        hier_name = fullfile(video_path, hier_dir_name ,hier_name);
        save(hier_name, 'hier');
    end
    cal_finish(fullfile(video_path, hier_dir_name));
    disp('cal_hier finished.');
else
    disp('cal_hier finished before.');
end