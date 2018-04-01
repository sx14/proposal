% process single video
% recall : hit object percentage
% smT-IoU : mT-IoU for single video
function [recall, smT_IoU, time_cost] = run(video_package_path,annotation_package_path,video_dir,mid_result_path,output_path,re_cal)
video_path = fullfile(video_package_path, video_dir);
annotation_path = fullfile(annotation_package_path, video_dir);
show_result = false;
if exist(fullfile(video_path),'dir')    % validate video path
    [proposals, time_cost] = proposal(video_package_path,video_dir,mid_result_path,output_path,re_cal);
    [result,annotations] = evaluate(video_dir,annotation_path,output_path,proposals);
    recall = result.recall;
    smT_IoU = result.smT_IoU;
    disp(['Finish:',video_dir,' ',num2str(time_cost.sum),' s.']);
    if show_result     % show result?
        input('show ?');
        show_hit(resized_imgs, result.hit ,proposals, annotations, org_height, org_width);
    end
else
    disp(['Orginal video not found:',video_path]);
    recall = NaN;
    smT_IoU = NaN;
    time_cost = [];
    frame_sum = NaN;
end