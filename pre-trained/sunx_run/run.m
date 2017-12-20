% 处理单个视频
% show_cands:是否要显示candidate
function run(video_path,annotation_path, img_suffix, hier, show_cands)
if exist(fullfile(video_path),'dir')
    resize_img(video_path, 'resized', img_suffix, 0);
    cal_flow(video_path, 'flow', 'resized', img_suffix, 0);
    cal_flow2(video_path,'flow2','resized', img_suffix, 0);
    if strcmp(hier,'hier')
        cal_hier(video_path,'hier','resized','flow',img_suffix, 0);
    else
        cal_hier_by_slic(video_path,'slic','resized','flow',img_suffix, 0);
    end
    get_result_for_one_video(video_path, annotation_path, 'resized','flow','flow2',hier, img_suffix,show_cands);
    disp(['Finish:',video_path]);
else
    error(['Orginal video not found:',video_path]);
end