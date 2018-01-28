clc;close all;
video_base_path = '/media/sunx/Data/ImageNet2/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNet2/Annotations';
mid_result_path = '/media/sunx/Data/ImageNet2/mid_result';
video_list = [
    'ILSVRC2015_train_00049001';
    'ILSVRC2015_train_00073028';
    'ILSVRC2015_train_00098005';
    'ILSVRC2015_train_00184001';
    'ILSVRC2015_train_00272028';
    'ILSVRC2015_train_00302017';
    'ILSVRC2015_train_00711000';
    'ILSVRC2015_train_00715002';
    'ILSVRC2015_train_00763000';
    'ILSVRC2015_train_00928000';
];
for i = 1:size(video_list,1)
    run(video_base_path,video_list(i,:),annotation_base_path,mid_result_path, output_path, true);
end
