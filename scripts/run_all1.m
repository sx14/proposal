function time_table = run_all1(video_base_path,mid_result_path,output_path,annotation_base_path)
all_videos = dir(fullfile(video_base_path,'*'));
video_sum = 10;
% video_sum = length(all_videos) - 2;
time_table = zeros(video_sum,4);    % time_cost / frame_sum
for i = 3:video_sum + 2
    video_dir = all_videos(i).name;
    [~,~,flow_time,flow2_time,time_cost,frame_sum] = run(video_base_path,video_dir,annotation_base_path,mid_result_path,output_path,true);
    time_table(i-2,1) = time_cost;
    time_table(i-2,2) = frame_sum;
    time_table(i-2,3) = flow_time;
    time_table(i-2,4) = flow2_time;
end