function run(video_path, img_suffix, hier)
if exist(fullfile(video_path),'dir')
    resize_img(video_path, 'resized', img_suffix, 0);
    cal_flow(video_path, 'flow', 'resized', img_suffix, 0);
    cal_flow2(video_path,'flow2','resized', img_suffix, 0);
    if strcmp(hier,'hier')
        cal_hier(video_path,'hier','resized','flow',img_suffix, 0);
    else
        cal_hier_by_slic(video_path,'slic','resized','flow',img_suffix, 1);
%         cal_hier_by_slic2(video_path,'slic','resized','flow',img_suffix, 0);
    end
    sunx_connect_image(video_path, 'resized','flow','flow2',hier, img_suffix);
else
    error(['Orginal video not found:',video_path]);
end