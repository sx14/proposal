clear;clc;close all;
video_base_path = '/media/sunx/Data/ImageNet/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNet/Annotations';
video_list = load('video_list.mat');
video_list = video_list.video_list;
% [recall, smT_IoU] = run([video_base_path,'/ILSVRC2015_VID_train_0001/'],'ILSVRC2015_train_00302002',[annotation_base_path,'/ILSVRC2015_VID_train_0001/'], output_path, true);
run_all(video_base_path,video_list,output_path,annotation_base_path)