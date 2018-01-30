clc;close all;
video_base_path = '/media/sunx/Data/ImageNetx/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNetx/Annotations';
mid_result_path = '/media/sunx/Data/ImageNetx/mid_result';
video_list = [
%     'ILSVRC2015_train_00016000';
    'ILSVRC2015_train_00020000';
%     'ILSVRC2015_train_00025035';
%     'ILSVRC2015_train_00046001';
%     'ILSVRC2015_train_00047001';
%     'ILSVRC2015_train_00050005';
%     'ILSVRC2015_train_00053001';
%     'ILSVRC2015_train_00053003';
%     'ILSVRC2015_train_00068015';
%     'ILSVRC2015_train_00098000';
%     'ILSVRC2015_train_00098001';
%     'ILSVRC2015_train_00098003';
%     'ILSVRC2015_train_00124006';
%     'ILSVRC2015_train_00150006';
%     'ILSVRC2015_train_00166002';
%     'ILSVRC2015_train_00172001';
%     'ILSVRC2015_train_00215006';
%     'ILSVRC2015_train_00682005';
%     'ILSVRC2015_train_00726000';
%     'ILSVRC2015_train_00729001';
%     'ILSVRC2015_train_00841000';
];
for i = 1:size(video_list,1)
    run(video_base_path,video_list(i,:),annotation_base_path,mid_result_path, output_path, true);
end
