clear;clc;close all;
video_base_path = '/media/sunx/Data/ImageNet/train';
output_path = '/home/sunx/output/ours_version2';
annotation_base_path = '/media/sunx/Data/ImageNet/Annotations';
mid_result_path = '/media/sunx/Data/ImageNet/mid_result';
all_results = dir(fullfile(output_path,'result','*.mat'));
for i = 1:length(all_results)
    result_mat_file_name = all_results(i).name;
    video_dir = result_mat_file_name(1:length(result_mat_file_name) - 4);
    run(video_base_path, video_dir,annotation_base_path,mid_result_path,output_path,false);
end

