% process one video
% recall : hit object percentage
% smT-IoU : mT-IoU for one video
function [recall, smT_IoU] = run(video_package_path, video_dir,annotation_package_path, output_path, re_cal)
video_path = fullfile(video_package_path, video_dir);
annotation_path = fullfile(annotation_package_path, video_dir);
show = true;
if exist(fullfile(video_path),'dir')    % validate video path
    [org_height, org_width, resized_imgs] = resize_img(video_path, 0);
    flow_set = cal_flow(video_path, resized_imgs, 0);
    flow2_set = cal_flow2(video_path, resized_imgs, 0);
    hier_set = cal_hier(video_path,flow_set, resized_imgs, 1);
    % entrance
    proposals = get_proposals(video_dir,output_path,org_height,org_width,hier_set,flow_set,flow2_set,resized_imgs,re_cal);
    % calculate result
    [result,annotations] = get_result(video_dir,annotation_path,output_path,proposals,re_cal);
    recall = result.recall;
    smT_IoU = result.smT_IoU;
    disp(['Finish:',video_path]);
    if show     % show result?
        input('show ?');
        show_hit(resized_imgs, result.hit ,proposals, annotations, org_height, org_width);
    end
else
    error(['Orginal video not found:',video_path]);
end