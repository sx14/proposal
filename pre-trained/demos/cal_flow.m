imgs = dir(fullfile(mcg_root, 'demos','video','*.jpg'));
for i = 1:length(imgs)-1
    num1=num2str(i,'%04d');
    img_name_1 = [num1,'.jpg'];
    num2=num2str(i+1,'%04d');
    img_name_2 = [num2,'.jpg'];
    I1 = imread(fullfile(mcg_root, 'demos','video',img_name_1));
    I2 = imread(fullfile(mcg_root, 'demos','video',img_name_2));
    flow = deepflow2(single(I1), single(I2));   % 预先算好放着
    flow_name = [num1,'.mat'];
    flow_name = fullfile(mcg_root, 'demos','flow',flow_name);
    save(flow_name, 'flow');
end
