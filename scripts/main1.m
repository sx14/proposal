clc;close all;
video_base_path = '/media/sunx/Data/ImageNetx/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNetx/Annotations';
mid_result_path = '/media/sunx/Data/ImageNetx/mid_result';
run(video_base_path,'ILSVRC2015_train_00321000',annotation_base_path,mid_result_path, output_path, true);
% show_hier(mid_result_path,'ILSVRC2015_train_00025006');