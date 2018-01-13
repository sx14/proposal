function run_all(video_base_path,package_video,mid_result_path,output_path,annotation_base_path)
% matlabpool 4;
for j = 1:5
    for i = j:5:size(package_video,1)
        video = package_video{i};
        run(video_base_path,video.video_dir,annotation_base_path,mid_result_path,output_path,false);
    end
end
% matlabpool close;