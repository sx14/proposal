close all; close all; clc;
dataset_path = '/home/sunx/dataset/ImageNet/train/chosen0';
annotation_path = '/home/sunx/dataset/ImageNet/Annotations/ILSVRC2015_VID_train_0000';
% run([dataset_path,'/ILSVRC2015_train_00001000'],[annotation_path,'/ILSVRC2015_train_00001000'],'JPEG','hier',true);   % 乌龟1
run([dataset_path,'/ILSVRC2015_train_00001002'],[annotation_path,'/ILSVRC2015_train_00001002'],'JPEG','hier',true);   % 乌龟2
% run([dataset_path,'/ILSVRC2015_train_00005001'],[annotation_path,'/ILSVRC2015_train_00005001'],'JPEG','hier',true);   % 狗1
% run([dataset_path,'/ILSVRC2015_train_00005003'],[annotation_path,'/ILSVRC2015_train_00005003'],'JPEG','hier',true);   % 狗2
% run([dataset_path,'/ILSVRC2015_train_00005004'],[annotation_path,'/ILSVRC2015_train_00005004'],'JPEG','hier',true);   % 狗3
% run([dataset_path,'/ILSVRC2015_train_00005005'],[annotation_path,'/ILSVRC2015_train_00005005'],'JPEG','hier',true);   % 狗4 ?
% run([dataset_path,'/ILSVRC2015_train_00008005'],[annotation_path,'/ILSVRC2015_train_00008005'],'JPEG','hier',true);   % 黑牛1
% run([dataset_path,'/ILSVRC2015_train_00008008'],[annotation_path,'/ILSVRC2015_train_00008008'],'JPEG','hier',true);   % 黑牛3
% run([dataset_path,'/ILSVRC2015_train_00015000'],[annotation_path,'/ILSVRC2015_train_00015000'],'JPEG','hier',true);   % 黑白？？？
% run([dataset_path,'/ILSVRC2015_train_00016001'],[annotation_path,'/ILSVRC2015_train_00016001'],'JPEG','hier',true);   % 车 ?
% run([dataset_path,'/ILSVRC2015_train_00016002'],[annotation_path,'/ILSVRC2015_train_00016002'],'JPEG','hier',true);   % 车
% run([dataset_path,'/ILSVRC2015_train_00020000'],[annotation_path,'/ILSVRC2015_train_00020000'],'JPEG','hier',true);     % 牛群
% run([dataset_path,'/ILSVRC2015_train_00022001'],[annotation_path,'/ILSVRC2015_train_00022001'],'JPEG','hier',true);   % 乌龟3
% run([dataset_path,'/ILSVRC2015_train_00025002'],[annotation_path,'/ILSVRC2015_train_00025002'],'JPEG','hier',true);   % 狗5
% run([dataset_path,'/ILSVRC2015_train_00027002'],[annotation_path,'/ILSVRC2015_train_00027002'],'JPEG','hier',true);   % 鲸
% run([dataset_path,'/ILSVRC2015_train_00028000'],[annotation_path,'/ILSVRC2015_train_00028000'],'JPEG','hier',true);   % 大象
% run([dataset_path,'/ILSVRC2015_train_00025005'],[annotation_path,'/ILSVRC2015_train_00025005'],'JPEG','hier',true);   % 自行车
% run([dataset_path,'/ILSVRC2015_train_00150006'],[annotation_path,'/ILSVRC2015_train_00150006'],'JPEG','hier',true);   % 一堆鸟
% run_all(dataset_path,annotation_path);



% dataset_path = '/home/sunx/dataset/ImageNet/';
% run([dataset_path,'/demo'],'jpg','hier');

% sunx_test_show([dataset_path,'/ILSVRC2015_train_00001002'], 'JPEG', 'hier');