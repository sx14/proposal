clear;clc;close all;
video_base_path = '/media/sunx/Data/ImageNetx/train';
annotation_base_path = '/media/sunx/Data/ImageNetx/Annotations';
% save intermediate result: resized frames, forward optical flow, backward optical flow, hierarchy
mid_result_output_path = '/media/sunx/Data/ImageNetx/mid_result';
% save proposals and check result
% result_output_path = '/media/sunx/Data/workspace/ICMR2018/output/x/exp_ours';
result_output_path = '/home/sunx/output/ours';
% time_cost:resize, flow, flow2, hier, proposal, sum
[recall, smT_IoU, time_cost] = run(video_base_path,annotation_base_path,'ILSVRC2015_train_00001006',mid_result_output_path, result_output_path, true);
% show hierarchical segmentation on each frame
% show_hier(mid_result_output_path,'ILSVRC2015_train_00001006', 14);

% run on all videos
% video_base_dir = dir(fullfile(video_base_path,'*'));
% for i = 3:length(video_base_dir)
%     video_dir = video_base_dir(i);
%     run(video_base_path,annotation_base_path,video_dir.name,mid_result_output_path, result_output_path, false);
% end



