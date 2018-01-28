clc;close all;
video_base_path = '/media/sunx/Data/ImageNet2/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNet2/Annotations';
mid_result_path = '/media/sunx/Data/ImageNet2/mid_result';
video_list = [
    'ILSVRC2015_train_00056005';
    'ILSVRC2015_train_00098007';
    'ILSVRC2015_train_00165013';
    'ILSVRC2015_train_00174000';
    'ILSVRC2015_train_00234019';
    'ILSVRC2015_train_00270001';
    'ILSVRC2015_train_00270002';
    'ILSVRC2015_train_00377000';
    'ILSVRC2015_train_00572000';
    'ILSVRC2015_train_00636000';
    'ILSVRC2015_train_00636001';
    'ILSVRC2015_train_00761000';
    'ILSVRC2015_train_00897009';
    'ILSVRC2015_train_01052000';
    'ILSVRC2015_train_01081000';
    'ILSVRC2015_train_01141000';
    'ILSVRC2015_train_01141005';
];
for i = 1:size(video_list,1)
    run(video_base_path,video_list(i,:),annotation_base_path,mid_result_path, output_path, true);
end
