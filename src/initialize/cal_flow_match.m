% calculate and save forward optical flow for each frame
function flow_set = cal_flow_match(video_package_path, video_dir, mid_result_path, resized_imgs, direction, re_cal)
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
img_suffix = '.JPEG';
video_flow_path = fullfile(mid_result_path,flow_dir_name,video_dir);
if ~exist(video_flow_path,'dir')
    mkdir(fullfile(mid_result_path,flow_dir_name), video_dir);
end
flow_set = cell(length(resized_imgs),1);
if ~exist(fullfile(video_flow_path,'finish'),'file') || re_cal == 1
    % the optical flow of the last frame is zero.
    for i = start_one:step:last_one
        flo_path = fullfile(video_flow_path,[num2str(i-1,'%06d'),'.flo']);
        if i ~= last_one
            I1_path = fullfile(video_package_path,video_dir,[num2str(i-1,'%06d'),img_suffix]);
            I2_path = fullfile(video_package_path,video_dir,[num2str(i,'%06d'),img_suffix]);
            cmd = ['./deepflow/deepmatching-static ',I1_path,' ',I2_path,' | ./deepflow/deepflow2-static ',I1_path,' ',I2_path,' ',flo_path,' -match -sintel'];
            system(cmd);
            flow = readFlowFile(flo_path);
        else
            flow = zeros(size(I1,1),size(I1,2),2);
            writeFlowFile(flow,flo_path);
        end
        flow_set{i} = flow;
    end
    cal_finish(video_flow_path);
    disp('cal_flow finished.');
else
    for i = start_one:step:last_one 
        num=num2str(i-1,'%06d');
        flo_path = fullfile(video_flow_path, [num,'.flo']);
        flow = readFlowFile(flo_path);
        flow_set{i} = flow;
    end
    disp('cal_flow finished before.');
end
