clc;close all;
video_base_path = '/media/sunx/Data/ImageNet/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNet/Annotations';
[recall, smT_IoU] = run(video_base_path,'ILSVRC2015_train_00058000',annotation_base_path, output_path, true);
% show_hier(fullfile(video_base_path,'ILSVRC2015_train_00058000'), 'JPEG', 'hier');