% org_video_path = '/media/sunx/Data/ImageNet/train';
% output_flow_path = '/media/sunx/Data/mid_result/flow';
% output_resize_path = '/media/sunx/Data/mid_result/resize';
% video_dirs = dir(fullfile(org_video_path,'*'));
% for i = 1:length(video_dirs)
%     org_video_dir = video_dirs(i);
%     org_video_flow_path = fullfile(org_video_path,org_video_dir.name,'flow');
%     if exist(org_video_flow_path,'dir') && exist(fullfile(org_video_flow_path,'finish'),'file')
%         out_video_flow_path = fullfile(output_flow_path,org_video_dir.name);
%         copyfile(org_video_flow_path,out_video_flow_path);
%     end
%     org_video_resize_path = fullfile(org_video_path,org_video_dir.name,'resized');
%     if exist(org_video_resize_path,'dir')
%         out_video_resize_path = fullfile(output_resize_path,org_video_dir.name);
%         copyfile(org_video_resize_path,out_video_resize_path);
%     end
% end