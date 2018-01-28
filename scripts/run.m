% process one video
% recall : hit object percentage
% smT-IoU : mT-IoU for one video
function [recall, smT_IoU,time_cost,frame_sum] = run(video_package_path,video_dir,annotation_package_path,mid_result_path,output_path,re_cal)
video_path = fullfile(video_package_path, video_dir);
annotation_path = fullfile(annotation_package_path, video_dir);
if exist(fullfile(output_path,'result', [video_dir,'.mat']),'file') && re_cal == false
    disp('done');
    return;
end
show = false;
if exist(fullfile(video_path),'dir')    % validate video path
    t0 = tic;
    [org_height, org_width, resized_imgs] = resize_img(video_package_path,video_dir,mid_result_path,1);
    frame_sum = length(resized_imgs);
    flow_set = cal_flow(video_package_path,video_dir,mid_result_path,resized_imgs,1);
    flow2_set = cal_flow2(video_package_path,video_dir,mid_result_path,resized_imgs,1);
    hier_set = cal_hier(video_package_path,video_dir,mid_result_path,flow_set, resized_imgs, 1);
    proposals = get_proposals(video_dir,output_path,org_height,org_width,hier_set,flow_set,flow2_set,resized_imgs,re_cal);
    time_cost=etime(clock,t0);
    [result,annotations] = get_result(video_dir,annotation_path,output_path,proposals,re_cal);
    recall = result.recall;
    smT_IoU = result.smT_IoU;
    disp(['Finish:',video_path]);
    if show     % show result?
        input('show ?');
        show_hit(resized_imgs, result.hit ,proposals, annotations, org_height, org_width);
    end
else
    disp(['Orginal video not found:',video_path]);
end