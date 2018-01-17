org_annotation_path = '/home/sunx/dataset/ImageNet/Annotations';
org_video_path = '/home/sunx/dataset/ImageNet/train';
org_video_path1 = '/media/sunx/Data/ImageNet/train';
% output_annotation_path = '/home/sunx/ImageNet/Annotations';
% output_video_path = '/home/sunx/ImageNet/train';
output_annotation_path = '/media/sunx/Data/ImageNet3/Annotations';
output_video_path = '/media/sunx/Data/ImageNet3/train';
video_list = load('video_list_good.mat');
video_list = video_list.video_list_good;
old_list = load('video_list.mat');
old_list = old_list.video_list;
for i = 1:size(video_list,1)
    video_info = video_list{i};
    package_dir = video_info.package_dir;
    video_dir = video_info.video_dir;
    finished = false;
    for j = 1:size(old_list,1)
        old_video = old_list{j};
        old_video_dir = old_video.video_dir;
        if strcmp(old_video_dir,video_dir) == true
            finished = true;
        end
    end
    org_annotation = fullfile(org_annotation_path,package_dir,video_dir);
    output_annotation = fullfile(output_annotation_path,video_dir);
    if finished == false
        org_video = fullfile(org_video_path,package_dir,video_dir);
    else
        org_video = fullfile(org_video_path1,video_dir);
        disp(video_dir);
        continue;
    end
    output_video = fullfile(output_video_path,video_dir);
    copyfile(org_video,output_video);
    copyfile(org_annotation,output_annotation);
end