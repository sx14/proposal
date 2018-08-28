% calculate and save forward optical flow for each frame
function flow_set = cal_flow_fn(video_dir, resize_root, flow_root,direction)
resized_video_path = fullfile(resize_root, video_dir);
output_path = fullfile(flow_root, video_dir);
if ~exist(output_path, 'dir')
    mkdir(output_path);
end
flownet_root_path = flownet_root();
img_suffix = 'JPEG';
if exist(resized_video_path,'dir')
    imgs = dir(fullfile(resized_video_path, ['*.',img_suffix]));
else
    error('cal_flow_fn : video not found.')
end
n_frame = length(imgs);
if strcmp(direction,'forward')
    start_one = 0;
    last_one = n_frame-1;
    step = 1;
elseif strcmp(direction,'backward')
    start_one = n_frame-1;
    last_one = 0;
    step = -1;
else
    error('param : direction is "forward" or "backward".');
end

flow_set = cell(n_frame, 1);
list_file_path = fullfile(flownet_root_path, 'list.txt');
if exist(list_file_path, 'file')
    delete(list_file_path);
end
img_list_file = fopen(list_file_path,'w');
is_list_empty = true;
% the optical flow of the last frame is zero.
for i = start_one:step:last_one
    flo_path = fullfile(output_path,[num2str(i,'%06d'),'.flo']);
    if ~exist(flo_path,'file')
        is_list_empty = false;
        if i ~= last_one
            I1_path = fullfile(resized_video_path,[num2str(i,'%06d'),'.',img_suffix]);
            I2_path = fullfile(resized_video_path,[num2str(i+step,'%06d'),'.',img_suffix]);
            if i ~= last_one-1
                fprintf(img_list_file, [I1_path ' ' I2_path ' ' flo_path '\n']);
            else
                fprintf(img_list_file, [I1_path ' ' I2_path ' ' flo_path]);
            end
        else
            I1 = imread(fullfile(resized_video_path,[num2str(i,'%06d'),'.',img_suffix]));
            flow = zeros(size(I1,1),size(I1,2),2);
            writeFlowFile(flow,flo_path);
        end
    end
end
fclose(img_list_file);
if ~is_list_empty
    model_path = fullfile(flownet_root_path, 'models', 'FlowNet2', 'FlowNet2_weights.caffemodel.h5');
    deploy_prototxt_path = fullfile(flownet_root_path, 'models', 'FlowNet2', 'FlowNet2_deploy.prototxt.template');
    PYTHONPATH = fullfile(flownet_root_path, 'python');
    python_script_path = fullfile(flownet_root_path, 'scripts', 'run-flownet-many.py');
    run_script_path = fullfile(flownet_root_path, 'scripts', 'run.sh');
    cal_flow_cmd = ['sh ' run_script_path ' ' PYTHONPATH ' ' python_script_path ' ' model_path ' ' deploy_prototxt_path ' ' list_file_path];
    system(cal_flow_cmd);
end
for i = start_one:step:last_one
    flo_path = fullfile(output_path,[num2str(i,'%06d'),'.flo']);
    flo = readFlowFile(flo_path);
    flow_set{i+1} = flo;
end
disp(['cal_',direction,'_flow finished.']);