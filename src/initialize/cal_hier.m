% 持久化所有的层次结构
function hier_set = cal_hier(video_path,flow_set,resized_imgs, re_cal)
hier_dir_name = 'hier';
if ~exist(fullfile(video_path, hier_dir_name),'dir')
    mkdir(fullfile(video_path), hier_dir_name);
end
hier_set = cell(length(resized_imgs),1);
if ~exist(fullfile(video_path, hier_dir_name,'finish'),'file') || re_cal == 1  % cal
    start_one = 0;
    last_one = length(resized_imgs) - 1;
    for i = start_one:last_one
        num=num2str(i,'%06d');
        I = resized_imgs{i+1};
        curr_flow = flow_set{i+1};
        [hier, ~] = get_hier(I, curr_flow);
        hier_set{i+1,1} = hier;
        hier_name = [num,'.mat'];
        hier_name = fullfile(video_path, hier_dir_name ,hier_name);
        save(hier_name, 'hier');
    end
    cal_finish(fullfile(video_path, hier_dir_name));
    disp('cal_hier finished.');
else
    start_one = 0;
    last_one = length(resized_imgs) - 1;
    for i = start_one:last_one
        num=num2str(i,'%06d');
        hier_name = [num,'.mat'];
        hier_path = fullfile(video_path, hier_dir_name, hier_name);
        heir_file = load(hier_path);
        hier_set{i+1} = heir_file.hier;
    end
    disp('cal_hier finished before.');
end