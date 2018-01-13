org_video_path = '/media/sunx/Data/ImageNet/train';
output_flow_path = '/media/sunx/Data/ImageNet/mid_result/flow';
output_flow2_path = '/media/sunx/Data/ImageNet/mid_result/flow2';
output_hier_path = '/media/sunx/Data/ImageNet/mid_result/hier';
output_resize_path = '/media/sunx/Data/ImageNet/mid_result/resize';
video_dirs = dir(fullfile(org_video_path,'*'));
for i = 1:length(video_dirs)
    org_video_dir = video_dirs(i);
    org_video_flow_path = fullfile(org_video_path,org_video_dir.name,'flow');
    org_video_flow2_path = fullfile(org_video_path,org_video_dir.name,'flow2');
    org_video_resize_path = fullfile(org_video_path,org_video_dir.name,'resized');
    org_video_hier_path = fullfile(org_video_path,org_video_dir.name,'hier');
    if exist(org_video_flow_path,'dir') && exist(fullfile(org_video_flow_path,'finish'),'file')
        out_video_flow_path = fullfile(output_flow_path,org_video_dir.name);
        copyfile(org_video_flow_path,out_video_flow_path);
    end
    if exist(org_video_resize_path,'dir') && exist(fullfile(org_video_resize_path,'finish'),'file')
        out_video_resize_path = fullfile(output_resize_path,org_video_dir.name);
        copyfile(org_video_resize_path,out_video_resize_path);
    end
    if  exist(org_video_flow2_path,'dir') && exist(fullfile(org_video_flow2_path,'finish'),'file')
        out_video_flow2_path = fullfile(output_flow2_path,org_video_dir.name);
        copyfile(org_video_flow2_path,out_video_flow2_path);
    end
    if  exist(org_video_hier_path,'dir') && exist(fullfile(org_video_hier_path,'finish'),'file')
        out_video_hier_path = fullfile(output_hier_path,org_video_dir.name);
        copyfile(org_video_hier_path,out_video_hier_path);
    end
end