% 持久化所有的正向光流
function cal_flow(video_path, flow_dir_name, resize_dir_name, img_suffix, re_cal)
if ~exist(fullfile(video_path, flow_dir_name),'dir')
    mkdir(fullfile(video_path), flow_dir_name);
end
if ~exist(fullfile(video_path, flow_dir_name,'finish'),'file') || re_cal == 1
    imgs = dir(fullfile(video_path, resize_dir_name, ['*.', img_suffix]));
    start_one = 0;
    last_one = length(imgs) - 1;
    for i = start_one:last_one    % 最后一个没有
        num1=num2str(i,'%06d');
        img_name_1 = [num1,'.', img_suffix];
        num2=num2str(i+1,'%06d');
        img_name_2 = [num2,'.', img_suffix];
        I1 = imread(fullfile(video_path, resize_dir_name, img_name_1));
        if i ~= last_one
            I2 = imread(fullfile(video_path, resize_dir_name, img_name_2));
            flow = deepflow2(single(I1), single(I2));
        else
            flow = zeros(size(I1,1),size(I2,2),2);
        end
        flow_name = [num1,'.mat'];
        flow_name = fullfile(video_path, flow_dir_name, flow_name);
        save(flow_name, 'flow');
    end
    cal_finish(fullfile(video_path, flow_dir_name));
    disp('cal_flow finished.');
else
    disp('cal_flow finished before.');
end
