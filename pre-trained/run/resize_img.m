function resize_img(video_path, resize_dir_name, suffix , re_cal)
if ~exist(fullfile(video_path, resize_dir_name),'dir')
    mkdir(fullfile(video_path), resize_dir_name);
end
if ~exist(fullfile(video_path, resize_dir_name,'finish'),'file') || re_cal == 1  % cal
    imgs = dir(fullfile(video_path, ['*.',suffix]));
    default_length = 500;
    for i = 0:length(imgs)-1
        num1=num2str(i,'%06d');
        img_name = [num1,'.',suffix];
        I1 = imread(fullfile(video_path, img_name));
        h = size(I1, 1);
        w = size(I1, 2);
        [max_length,~] = max([w,h]);
        if max_length > default_length
            scale =  default_length / max_length;
            I1 = imresize(I1, scale);
        end
        resized_img_name = fullfile(video_path, resize_dir_name, img_name);
        imwrite(I1, resized_img_name);
    end
    finish(fullfile(video_path, resize_dir_name));
    disp('resize_img finished.');
else
    disp('resize_img finished before.');
end