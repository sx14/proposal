function run_all1(video_base_path,mid_result_path,output_path,annotation_base_path)
all_videos = dir(fullfile(video_base_path,'*'));
for i = 3:length(all_videos)
    video_dir = all_videos(i).name;
    run(video_base_path,video_dir,annotation_base_path,mid_result_path,output_path,false);
end