clc;close all;
video_base_path = '/media/sunx/Data/ImageNet/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNet/Annotations';
mid_result_path = '/media/sunx/Data/ImageNet/mid_result';
[recall, smT_IoU] = run(video_base_path,'ILSVRC2015_train_00025006',annotation_base_path,mid_result_path, output_path, true);
% show_hier(mid_result_path,'ILSVRC2015_train_00020000');