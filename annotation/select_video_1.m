close all; close all; clear; clc;
base_path = '/home/sunx/dataset/ImageNet/Annotations';
video_package_list = ['ILSVRC2015_VID_train_0000';'ILSVRC2015_VID_train_0001';'ILSVRC2015_VID_train_0002';'ILSVRC2015_VID_train_0003'];
file_name = 'annotation_info.mat';
if ~exist(file_name,'file')
    annotation_info = get_object_num(base_path, video_package_list, 4000);
    save(file_name, 'annotation_info');
else
    annotation_file = load(file_name);
    annotation_info  = annotation_file.annotation_info;
end

% video_sum = 0;
% dis = zeros(10*4000,1);
% for i = 1:10
%     for j = 1:4000
%         if isempty(annotation_info{i,j})
%             continue;
%         else
%             video_sum = video_sum + 1;
%             dis((i-1)*4000+j) = min(annotation_info{i,j}.obj_num,10);
%         end
%     end
% end

dis = dis(dis > 0);
hist(dis);
avg_obj_num = sum(dis) / length(dis);   % 2.065

temp_annotations = cell(10,4000);
for i = 1:size(annotation_info,1)
    counter = 1;
    for j = 1:size(annotation_info,2)
        a = annotation_info{i,j};
        if ~isempty(a) && a.length <= 300
            temp_annotations{i,counter} = a;
            counter = counter + 1;
        end
    end
end

distribution1 = zeros(10,2);
distribution = zeros(10,1);
for i = 1:size(temp_annotations,1)
    annotations = temp_annotations(i,:);
    sum_counter = 0;
    mid_more_counter = 0;
    mid_less_counter = 0;
    for j = 1:size(annotations,2)
        annotation = annotations{1,j};
        if ~isempty(annotation)
            mid_ratio = annotation.mid_obj_num / annotation.obj_num;
            if mid_ratio > 0.5
                mid_more_counter = mid_more_counter + 1;
            else
                mid_less_counter = mid_less_counter + 1;
            end
            sum_counter = sum_counter + 1;
        end
    end
    distribution(i,1) = sum_counter;
    distribution1(i,1) = mid_more_counter;
    distribution1(i,2) = mid_less_counter;
end

number = [35;35;35;35;38;39;22;11;23;27];
step = floor(distribution ./ number);
video_list = cell(sum(number),1);
video_name_list = '';
index = 1;
for i = 1:size(temp_annotations,1)
    annotations = temp_annotations(i,:);
    for j = 0:number(i) - 1
        video = annotations{j*step(i) + 1};
        video.object_number = i;
        video_list{index,1} = video;
        video_name = video.video_dir;
        if index == 1
            video_name_list = video_name;
        else
            video_name_list = [video_name_list;video_name];
        end
        index = index + 1;
    end
end

video_list_path = '/home/sunx/output/selected';
video_list_file_mat = 'video_list.mat';
video_list_file_txt = 'video_list.txt';
output(video_list_path, video_list_file_txt, video_name_list, 'txt');
save(video_list_file_mat, 'video_list');