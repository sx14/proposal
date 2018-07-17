function show_hier(mid_result_path,video_dir)
video_resize_path = fullfile(mid_result_path,'resize',video_dir);
video_hier_path = fullfile(mid_result_path,'hier',video_dir);
imgs = dir(fullfile(video_resize_path,['*.', 'JPEG']));
frame_sum = length(imgs);
net = zeros(800,frame_sum,3);
for i = 0:frame_sum - 1
    num1=num2str(i,'%06d');
    img_name = [num1,['.','JPEG']];
    I = imread(fullfile(video_resize_path,img_name));
    hier_name = [num1,'.mat'];
    curr_hier = load(fullfile(video_hier_path,hier_name));
    curr_hier  = curr_hier.hier;
    show.image = I;
    show.color_line = init_color(512);
    show.line_color = zeros(6000,1);  
    [net,~] = grow_volumes(i+1, net ,curr_hier);
    show_frame(show, net, curr_hier, i+1);
    X = sprintf('Frame %d finished.',i);
    disp(X)
    input('continue?');
    close all;
end

