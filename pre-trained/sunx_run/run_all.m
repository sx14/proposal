function run_all(dataset_path,annotation_path)
videos = dir(fullfile(dataset_path,'*'));
video_sum = 0;
recall_sum = 0;
smT_IoU_sum = 0;
for i = 1:length(videos)
    video = videos(i);
    if (video.isdir && ~strcmp(video.name,'.') && ~strcmp(video.name,'..') )
        [recall, smT_IoU] = run(fullfile(dataset_path,video.name),fullfile(annotation_path,video.name),'JPEG','hier',false);
        recall_sum = recall_sum + recall;
        smT_IoU_sum = smT_IoU_sum + smT_IoU;
        video_sum = video_sum + 1;
    end
end
recall = recall_sum / video_sum;
mT_IoU = smT_IoU_sum / video_sum;
output_recall = sprintf('recall : %.2f%%', recall * 100);
output_mT_IoU = sprintf('mT_IoU : %.2f%%', mT_IoU * 100);
output_info = [output_recall;output_mT_IoU];
output(dataset_path, 'result', output_info, 'txt');

