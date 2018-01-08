% 持久化所有的正向光流
function flow_set = cal_flow(video_path, resized_imgs, re_cal)
flow_dir_name = 'flow';
if ~exist(fullfile(video_path, flow_dir_name),'dir')
    mkdir(fullfile(video_path), flow_dir_name);
end
flow_set = cell(length(resized_imgs),1);
if ~exist(fullfile(video_path, flow_dir_name,'finish'),'file') || re_cal == 1
    start_one = 0;
    last_one = length(resized_imgs) - 1;
    for i = start_one:last_one    % 最后一个没有
        num=num2str(i,'%06d');
        I1 = resized_imgs{i+1};
        if i ~= last_one
            I2 = resized_imgs{i+2};
            flow = deepflow2(single(I1), single(I2));
        else
            flow = zeros(size(I1,1),size(I1,2),2);
        end
        flow_set{i+1} = flow;
        flow_name = [num,'.mat'];
        flow_name = fullfile(video_path, flow_dir_name, flow_name);
        save(flow_name, 'flow');
    end
    cal_finish(fullfile(video_path, flow_dir_name));
    disp('cal_flow finished.');
else
    start_one = 0;
    last_one = length(resized_imgs) - 1;
    for i = start_one:last_one 
        num1=num2str(i,'%06d');
        flow_name = [num1,'.mat'];
        flow_path = fullfile(video_path, flow_dir_name, flow_name);
        try
            flow_file = load(flow_path);
        catch
            flow_file.flow = zeros(size(flow_set{i}));
        end
        flow_set{i+1} = flow_file.flow;
    end
    disp('cal_flow finished before.');
end
