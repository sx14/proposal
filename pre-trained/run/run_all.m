function run_all(dataset_path)
videos = dir(fullfile(dataset_path,'*'));
for i = 1:4:length(videos)
    video = videos(i);
    run(fullfile(dataset_path,video.name),'JPEG', 'hier');
end
