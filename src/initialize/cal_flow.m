% calculate and save forward optical flow for each frame
function flow_set = cal_flow(video_dir, mid_result_path, resized_imgs, direction, re_cal)
if strcmp(direction,'forward')
    flow_dir_name = 'flow';
    start_one = 1;
    last_one = length(resized_imgs);
    step = 1;
elseif strcmp(direction,'backward')
    flow_dir_name = 'flow2';
    start_one = length(resized_imgs);
    last_one = 1;
    step = -1;
else
    error('param : direction is "forward" or "backward".');
end
video_flow_path = fullfile(mid_result_path,flow_dir_name,video_dir);
if ~exist(video_flow_path,'dir')
    mkdir(fullfile(mid_result_path,flow_dir_name), video_dir);
end
flow_set = cell(length(resized_imgs),1);
if ~exist(fullfile(video_flow_path,'finish'),'file') || re_cal == 1
    % the optical flow of the last frame is zero.
    for i = start_one:step:last_one
        num=num2str(i-1,'%06d');
        I1 = resized_imgs{i};
        if i ~= last_one
            I2 = resized_imgs{i+step};
            flow = deepflow2(single(I1), single(I2));
        else
            flow = zeros(size(I1,1),size(I1,2),2);
        end
        flow_set{i} = flow;
        flow_name = [num,'.mat'];
        flow_name = fullfile(video_flow_path, flow_name);
        save(flow_name, 'flow');
    end
    cal_finish(video_flow_path);
    disp('cal_flow finished.');
else
    for i = start_one:step:last_one 
        num1=num2str(i-1,'%06d');
        flow_name = [num1,'.mat'];
        flow_path = fullfile(video_flow_path, flow_name);
        try
            flow_file = load(flow_path);
        catch
            flow_file.flow = zeros(size(flow_set{i}));
        end
        flow_set{i} = flow_file.flow;
    end
    disp('cal_flow finished before.');
end
