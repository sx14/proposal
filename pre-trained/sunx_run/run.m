% 处理单个视频
% show_cands:是否要显示candidate
function [recall, smT_IoU] = run(base_path, package_dir, video_dir,annotation_path, output_path)
video_path = fullfile(base_path, package_dir, video_dir);
if exist(fullfile(video_path),'dir')
    show_cands = true;
    resize_img(video_path, 0);
    cal_flow(video_path, 0);
    cal_flow2(video_path, 0);
    cal_hier(video_path, 0);
    [recall, smT_IoU] = get_result_for_one_video(base_path, package_dir, video_dir, annotation_path,show_cands,output_path);
    disp(['Finish:',video_path]);
else
    error(['Orginal video not found:',video_path]);
end