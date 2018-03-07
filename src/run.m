% process one video
% recall : hit object percentage
% smT-IoU : mT-IoU for one video
function [recall, smT_IoU, time_cost, frame_sum] = run(video_package_path,annotation_package_path,video_dir,mid_result_path,output_path,re_cal)
video_path = fullfile(video_package_path, video_dir);
annotation_path = fullfile(annotation_package_path, video_dir);
show_result = false;
if exist(fullfile(video_path),'dir')    % validate video path
    t0 = clock;
    [org_height, org_width, resized_imgs] = resize_img(video_package_path,video_dir,mid_result_path,0);
    t1 = clock;
    resize_time_cost = etime(t1, t0);
    flow_set = cal_flow(video_package_path,video_dir,mid_result_path,resized_imgs,0);
    t2 = clock;
    flow_time_cost = etime(t2,t1);
    flow2_set = cal_flow2(video_package_path,video_dir,mid_result_path,resized_imgs,0);
    t3 = clock;
    flow2_time_cost = etime(t3,t2);
    hier_set = cal_hier(video_package_path,video_dir,mid_result_path,flow_set, resized_imgs, 0);
    t4 = clock;
    hier_time_cost = etime(t4,t3);
    proposals = get_proposals(video_dir,output_path,org_height,org_width,hier_set,flow_set,flow2_set,resized_imgs,re_cal);
    proposal_time_cost=etime(clock,t4);
    time_cost.resize = resize_time_cost;
    time_cost.flow = flow_time_cost;
    time_cost.flow2 = flow2_time_cost;
    time_cost.hier = hier_time_cost;
    time_cost.proposal = proposal_time_cost;
    time_cost.sum = resize_time_cost + flow_time_cost + flow2_time_cost + hier_time_cost + proposal_time_cost;
    [result,annotations] = check_proposals(video_dir,annotation_path,output_path,proposals,re_cal);
    recall = result.recall;
    smT_IoU = result.smT_IoU;
    frame_sum = length(resized_imgs);
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