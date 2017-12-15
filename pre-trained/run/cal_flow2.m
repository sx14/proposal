function cal_flow2(video_path, flow_dir_name, resize_dir_name, img_suffix, re_cal)
if ~exist(fullfile(video_path, flow_dir_name),'dir')
    mkdir(fullfile(video_path), flow_dir_name);
end
if ~exist(fullfile(video_path, flow_dir_name,'finish'),'file') || re_cal == 1 % cal
    imgs = dir(fullfile(video_path, resize_dir_name, ['*.', img_suffix]));
    last_one = length(imgs) - 1;
    if last_one > 80
        last_one = 80;
    end
    for i = last_one:-1:1     % 第0个没有
        num1=num2str(i,'%06d');
        img_name_1 = [num1,'.', img_suffix];
        num2=num2str(i-1,'%06d');
        img_name_2 = [num2,'.', img_suffix];
        I1 = imread(fullfile(video_path, resize_dir_name, img_name_1));
        I2 = imread(fullfile(video_path, resize_dir_name, img_name_2));
        flow = deepflow2(single(I1), single(I2));   % 预先算好放着
        flow_name = [num1,'.mat'];
        flow_name = fullfile(video_path, flow_dir_name, flow_name);
        save(flow_name, 'flow');
    end
    finish(fullfile(video_path, flow_dir_name));
    disp('cal_flow2 finished.');
else
    disp('cal_flow2 finished before.');
end
