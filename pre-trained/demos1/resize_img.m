imgs = dir(fullfile(mcg_root, 'demos1','video','*.JPEG'));
for i = 0:length(imgs)-1
    num1=num2str(i,'%06d');
    img_name_1 = [num1,'.JPEG'];
    I1 = imread(fullfile(mcg_root, 'demos1','video',img_name_1));
    I2 = imresize(I1,0.5);
    new_img_name = fullfile(mcg_root, 'demos1','video1',img_name_1);
    imwrite(I2,new_img_name);
end
