% 持久化所有的层次结构
function cal_hier(video_path, re_cal)
hier_dir_name = 'hier';
resize_dir_name = 'resized';
img_suffix = 'JPEG';
flow_dir_name = 'flow';
if ~exist(fullfile(video_path, hier_dir_name),'dir')
    mkdir(fullfile(video_path), hier_dir_name);
end
if ~exist(fullfile(video_path, hier_dir_name,'finish'),'file') || re_cal == 1  % cal
    imgs = dir(fullfile(video_path, resize_dir_name, ['*.', img_suffix]));
    start_one = 0;
    last_one = length(imgs) - 1;
    for i = start_one:last_one
        num=num2str(i,'%06d');
        img_name = [num,'.', img_suffix];
        I = imread(fullfile(video_path, resize_dir_name,img_name));
        flow_name = [num,'.mat'];
        try
        curr_flow = load(fullfile(video_path, flow_dir_name ,flow_name));
        curr_flow  = curr_flow.flow;
        catch
            curr_flow = zeros(size(I,1),size(I,2),2);
        end
        [hier, ~] = get_hier(I, curr_flow);
        hier_name = [num,'.mat'];
        hier_name = fullfile(video_path, hier_dir_name ,hier_name);
        save(hier_name, 'hier');
    end
    cal_finish(fullfile(video_path, hier_dir_name));
    disp('cal_hier finished.');
else
    disp('cal_hier finished before.');
end