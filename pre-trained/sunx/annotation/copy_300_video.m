org_annotation_path = '/home/sunx/dataset/ImageNet/Annotations';
org_video_path = '/home/sunx/dataset/ImageNet/train';
output_annotation_path = '/home/sunx/ImageNet/Annotations';
output_video_path = '/home/sunx/ImageNet/train';
video_list = load('video_list.mat');
video_list = video_list.video_list;
for i = 1:size(video_list,1)
    video_info = video_list{i};
    package_dir = video_info.package_dir;
    video_dir = video_info.video_dir;
    output_video_package_path = fullfile(output_video_path,package_dir);
    output_annotation_package_path = fullfile(output_annotation_path,package_dir);
    org_annotation = fullfile(org_annotation_path,package_dir,video_dir);
    output_annotation = fullfile(output_annotation_path,video_dir);
    org_video = fullfile(org_video_path,package_dir,video_dir);
    output_video = fullfile(output_video_path,video_dir);
    copyfile(org_video,output_video);
%     copyfile(org_annotation,output_annotation);
end