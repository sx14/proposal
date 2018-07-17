clear;clc;close all;
video_base_path = '/media/sunx/Data/ImageNetx/train';
annotation_base_path = '/media/sunx/Data/ImageNetx/Annotations';
% save intermediate result: resized frames, forward optical flow, backward optical flow, hierarchy
mid_result_output_path = '/media/sunx/Data/ImageNetx/mid_result';
% save proposals and check result
% result_output_path = '/media/sunx/Data/workspace/ICMR2018/output/x/exp_ours';
result_output_path = '/home/sunx/output/ours';
% time_cost:resize, flow, flow2, hier, proposal, sum
[recall, smT_IoU, time_cost] = run(video_base_path,annotation_base_path,'ILSVRC2015_train_00053010',mid_result_output_path, result_output_path, false);
% show hierarchical segmentation on each frame
% show_hier(mid_result_output_path,'ILSVRC2015_train_00001006');

% run on all videos
% video_base_dir = dir(fullfile(video_base_path,'*'));
% for i = 3:length(video_base_dir)
%     video_dir = video_base_dir(i);
%     run(video_base_path,annotation_base_path,video_dir.name,mid_result_output_path, result_output_path, false);
% end


ffmpeg -r 1/5 -i %06d.JPEG -c:v libx264 -vf fps=20 -pix_fmt yuv420p out.mp4


