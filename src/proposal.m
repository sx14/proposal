% process single video
% recall : hit object percentage
% smT-IoU : mT-IoU for single video
function [proposals, time_cost, mask_generation_package] = proposal(video_package_path,video_dir,mid_result_path,output_path,re_cal)
if ~exist(fullfile(mid_result_path,'resize'),'dir')
    mkdir(mid_result_path,'resize');
end
if ~exist(fullfile(mid_result_path,'flow'),'dir')
    mkdir(mid_result_path,'flow');
end
if ~exist(fullfile(mid_result_path,'flow2'),'dir')
    mkdir(mid_result_path,'flow2');
end
if ~exist(fullfile(mid_result_path,'hier'),'dir')
    mkdir(mid_result_path,'hier');
end
video_path = fullfile(video_package_path, video_dir);
if exist(fullfile(video_path),'dir')    % validate video path
    t0 = clock;
    % resize frames to fixed size (long edge = 500)
    [org_height, org_width, resized_imgs] = resize_img(video_package_path,fullfile(mid_result_path,'resize'),video_dir);
    t1 = clock;
    resize_time_cost = etime(t1, t0);
    % forward optical flow estimation
%     flow_set = cal_flow_match(fullfile(mid_result_path,'resize'),fullfile(mid_result_path,'flow'),video_dir,'forward');
        flow_set = cal_flow(video_dir,fullfile(mid_result_path,'flow'),resized_imgs,'forward');
    t2 = clock;
    % backward optical flow estimation
    flow_time_cost = etime(t2,t1);
%     flow2_set = cal_flow_match(fullfile(mid_result_path,'resize'),fullfile(mid_result_path,'flow2'),video_dir,'backward');
        flow2_set = cal_flow(video_dir,fullfile(mid_result_path,'flow2'),resized_imgs,'backward');
    t3 = clock;
    flow2_time_cost = etime(t3,t2);
    % hierarchical segmentation with MCG
    hier_set = cal_hier(fullfile(mid_result_path,'hier'),video_dir,flow_set, resized_imgs);
    t4 = clock;
    hier_time_cost = etime(t4,t3);
    % generate no more than 1000 trajectory proposals
    [proposals,mask_generation_package] = get_trajectory_proposals(video_dir,output_path,org_height,org_width,hier_set,flow_set,flow2_set,resized_imgs,re_cal);
    proposal_time_cost=etime(clock,t4);
    time_cost.resize = resize_time_cost;
    time_cost.flow = flow_time_cost;
    time_cost.flow2 = flow2_time_cost;
    time_cost.hier = hier_time_cost;
    time_cost.proposal = proposal_time_cost;
    time_cost.sum = resize_time_cost + flow_time_cost + flow2_time_cost + hier_time_cost + proposal_time_cost;
else
    disp(['Orginal video not found : ',video_path]);
    proposals = [];
    time_cost = [];
end