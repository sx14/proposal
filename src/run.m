% process single video
% recall : hit object percentage
% smT-IoU : mT-IoU for single video
function [recall, smT_IoU, time_cost] = run(video_package_path,annotation_package_path,video_dir,mid_result_path,output_path,re_cal)
video_path = fullfile(video_package_path, video_dir);
annotation_path = fullfile(annotation_package_path, video_dir);
generate_trajectory = true;
generate_mask = false;
if exist(fullfile(video_path),'dir')    % validate video path
    [proposals, time_cost, mask_generation_package] = proposal(video_package_path,video_dir,mid_result_path,output_path,re_cal);
    [result,annotations] = evaluate(video_dir,annotation_path,output_path,proposals);
    recall = result.recall;
    smT_IoU = result.smT_IoU;
    disp(['Finish:',video_dir,' ',num2str(time_cost.sum),' s.']);
    if generate_trajectory     % show result?
        resized_imgs = mask_generation_package.resized_imgs;
        org_height = mask_generation_package.org_height;
        org_width = mask_generation_package.org_width;
        generate_trajectories(output_path, video_dir, resized_imgs, result.hit ,proposals, annotations, org_height, org_width);
    end
    if generate_mask
        if isfield(mask_generation_package,'proposal_volume_group')
            generate_masks(output_path,video_dir,result,proposals,mask_generation_package, 1);
        else
            disp('Set re_cal as "true", then mask can be generated');
        end
    end
else
    disp(['Orginal video not found:',video_path]);
    recall = NaN;
    smT_IoU = NaN;
    time_cost = [];
end