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

video_list_good = cell(300,1);
video_name_list = '';
index = 0;
for i = 1:size(temp_annotations,1) - 2
    annotations = temp_annotations(i,:);
    for j = 1:size(annotations,2)
        video = annotations{1,j};
        if ~isempty(video)
            mid_ratio = video.mid_obj_num / video.obj_num;
            if mid_ratio > 0.5
                continue;
            else
                index = index + 1;
                video_name = video.video_dir;
                if index == 1
                    video_name_list = video_name;
                else
                    video_name_list = [video_name_list;video_name];
                end
                video_list_good{index} = video;
            end
        end
    end
end
video_list_good = video_list_good(1:index);
video_list_path = '/home/sunx/output/selected';
video_list_file_mat = 'video_list_good.mat';
video_list_file_txt = 'video_list_good.txt';
output(video_list_path, video_list_file_txt, video_name_list, 'txt');
save(video_list_file_mat, 'video_list_good');