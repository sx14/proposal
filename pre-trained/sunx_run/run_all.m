function run_all(dataset_path,annotation_path)
videos = dir(fullfile(dataset_path,'*'));
for i = 3:length(videos)
    video = videos(i);
    run(fullfile(dataset_path,video.name),fullfile(annotation_path,video.name),'JPEG','hier',false);
end
