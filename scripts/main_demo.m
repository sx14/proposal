close all; close all; clc;
base_path = '/home/sunx/dataset/ImageNet/train';
package_dir = 'chosen0';
annotation_path = '/home/sunx/dataset/ImageNet/Annotations/ILSVRC2015_VID_train_0000';
output_path = '/home/sunx/output/ours_temp';
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00001000',annotation_path,output_path,true);   % 乌龟1 find all | good
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00001001',annotation_path,output_path,true);   % 乌龟2 bad | 太难
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00001002',annotation_path,output_path,true);   % 乌龟4 find all | normal 分割不理想
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00005001',annotation_path,output_path,true);   % 狗 find all | normal 头和身体不相邻
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00005003',annotation_path,output_path,true);   % 狗2 find all | good
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00005004',annotation_path,output_path,true);   % 狗3 find all | normal
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00005005',annotation_path,output_path,true);   % * 狗4 failed | 跑太远太小了，匹配失败
% run([dataset_path,'/ILSVRC2015_train_00005012'],[annotation_path,'/ILSVRC2015_train_00005012'],'JPEG','hier',true);   % 狗5 failed | 分割问题
% run(fullfile(base_path,package_dir),'/ILSVRC2015_train_00008005',annotation_path,output_path,true);   % * 黑牛1 find all | not good 分割问题
% run([dataset_path,'/ILSVRC2015_train_00010000'],[annotation_path,'/ILSVRC2015_train_00010000'],'JPEG','hier',true);   % 多个自行车 failed | 太难了
% run(base_path,package_dir,'/ILSVRC2015_train_00012009',[annotation_path,'/ILSVRC2015_train_00012009'], output_path);   % 两匹马 find all | not good 匹配误差还是分割有待排查
% run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00008008',annotation_path,output_path,true);   % 黑牛3 find all | good 
% run([dataset_path,'/ILSVRC2015_train_00015000'],[annotation_path,'/ILSVRC2015_train_00015000'],'JPEG','hier',true);   % 黑白 failed | 太难
% run([dataset_path,'/ILSVRC2015_train_00016001'],[annotation_path,'/ILSVRC2015_train_00016001'],'JPEG','hier',true);   % 车 find all | not good
% run([dataset_path,'/ILSVRC2015_train_00016002'],[annotation_path,'/ILSVRC2015_train_00016002'],'JPEG','hier',true);   % 车 not all | special
run(fullfile(base_path, package_dir),'/ILSVRC2015_train_00020000',annotation_path,output_path,true);   % * 牛群 not all | not good 分割问题
% run(fullfile(base_path,package_dir),'/ILSVRC2015_train_00022001',annotation_path,output_path,true);   % 乌龟3 find all | good
% run([dataset_path,'/ILSVRC2015_train_00025002'],[annotation_path,'/ILSVRC2015_train_00025002'],'JPEG','hier',true);   % 狗5 find all | normal
% run(fullfile(base_path,package_dir),'/ILSVRC2015_train_00027002',annotation_path,output_path,true);   % 鲸 find all | normal
% run([dataset_path,'/ILSVRC2015_train_00028000'],[annotation_path,'/ILSVRC2015_train_00028000'],'JPEG','hier',true);   % 大象 failed | 分割问题
% run([dataset_path,'/ILSVRC2015_train_00025005'],[annotation_path,'/ILSVRC2015_train_00025005'],'JPEG','hier',true);   % 自行车 find all | normal
% run_all(dataset_path,annotation_path);

% show_hier([fullfile(base_path, package_dir),'/ILSVRC2015_train_00020000'], 'JPEG', 'hier');

dataset_path = '/home/sunx/dataset/ImageNet/train';
package_dir = 'chosen1';
annotation_path = '/home/sunx/dataset/ImageNet/Annotations/ILSVRC2015_VID_train_0001';
% run([dataset_path,'/ILSVRC2015_train_00033010'],[annotation_path,'/ILSVRC2015_train_00033010'],'JPEG','hier',true);   % 熊
% run([dataset_path,'/ILSVRC2015_train_00145001'],[annotation_path,'/ILSVRC2015_train_00145001'],'JPEG','hier',true);   % 蜥蜴
% run([dataset_path,'/ILSVRC2015_train_00146001'],[annotation_path,'/ILSVRC2015_train_00146001'],'JPEG','hier',true);   % 鹿 failed | 待排查
% run(fullfile(base_path,package_dir),'/ILSVRC2015_train_00150006',annotation_path,output_path,true);   % 一堆鸟 find all | not good
% run(fullfile(base_path,package_dir),'/ILSVRC2015_train_00150010',annotation_path,output_path,true);   % 两个鸟叠起来 find all | not good
% run([dataset_path,'/ILSVRC2015_train_00176000'],[annotation_path,'/ILSVRC2015_train_00176000'],'JPEG','hier',true);   % 小红车 find all | good
% run([dataset_path,'/ILSVRC2015_train_00185000'],[annotation_path,'/ILSVRC2015_train_00185000'],'JPEG','hier',true);   % 四只羊 find all | bug???
% run(fullfile(base_path,package_dir),'/ILSVRC2015_train_00191000',annotation_path,output_path,true);   % 熊猫 find all | not good 串断了





