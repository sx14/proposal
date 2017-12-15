function cal_flow(video_path, flow_dir_name, resize_dir_name, img_suffix, re_cal)
if ~exist(fullfile(video_path, flow_dir_name),'dir')
    mkdir(fullfile(video_path), flow_dir_name);
end
if ~exist(fullfile(video_path, flow_dir_name,'finish'),'file') || re_cal == 1
    imgs = dir(fullfile(video_path, resize_dir_name, ['*.', img_suffix]));
    last_one = length(imgs) - 2;
    if last_one > 79    % 最多算80个
        last_one = 79;
    end
    for i = 0:last_one    % 最后一个没有
        % for i = 0:10
        num1=num2str(i,'%06d');
        img_name_1 = [num1,'.', img_suffix];
        num2=num2str(i+1,'%06d');
        img_name_2 = [num2,'.', img_suffix];
        I1 = imread(fullfile(video_path, resize_dir_name, img_name_1));
        I2 = imread(fullfile(video_path, resize_dir_name, img_name_2));
        flow = deepflow2(single(I1), single(I2));
        flow_name = [num1,'.mat'];
        flow_name = fullfile(video_path, flow_dir_name, flow_name);
        save(flow_name, 'flow');
    end
    finish(fullfile(video_path, flow_dir_name));
    disp('cal_flow finished.');
else
    disp('cal_flow finished before.');
end
