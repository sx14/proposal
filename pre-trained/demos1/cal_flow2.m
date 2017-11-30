imgs = dir(fullfile(mcg_root, 'demos1','video1','*.JPEG'));
for i = 11 : -1 : 2
    num1=num2str(i,'%06d');
    img_name_1 = [num1,'.JPEG'];
    num2=num2str(i-1,'%06d');
    img_name_2 = [num2,'.JPEG'];
    I1 = imread(fullfile(mcg_root, 'demos1','video1',img_name_1));
    I2 = imread(fullfile(mcg_root, 'demos1','video1',img_name_2));
    flow = deepflow2(single(I1), single(I2));   % 预先算好放着
    flow_name = [num1,'.mat'];
    flow_name = fullfile(mcg_root, 'demos1','flow2',flow_name);
    save(flow_name, 'flow');
end
