function run_all(video_base_path,package_video,output_path,annotation_base_path)
% matlabpool 4;
for i = 1:size(package_video,1)
    video = package_video{i};
    annotation_package_path = fullfile(annotation_base_path,video.package_dir);
    video_package_path = fullfile(video_base_path,video.package_dir);
    run(video_package_path,video.video_dir,annotation_package_path,output_path,false);
end
% matlabpool close;