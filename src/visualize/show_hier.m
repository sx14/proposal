function show_hier(mid_result_path,video_dir, frame)
video_resize_path = fullfile(mid_result_path,'resize',video_dir);
video_hier_path = fullfile(mid_result_path,'hier',video_dir);
num1=num2str(frame,'%06d');
img_name = [num1,['.','JPEG']];
I = imread(fullfile(video_resize_path,img_name));
hier_name = [num1,'.mat'];
curr_hier = load(fullfile(video_hier_path,hier_name));
curr_hier  = curr_hier.hier;
show_frame(I,curr_hier);
X = sprintf('Frame %d finished.',frame);
disp(X)
input('continue?');
close all;

