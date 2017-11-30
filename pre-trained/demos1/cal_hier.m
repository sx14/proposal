imgs = dir(fullfile(mcg_root, 'demos1','video1','*.JPEG'));
% for i = 1:length(imgs)-1
for i = 1:10
    num=num2str(i,'%06d');
    img_name = [num,'.JPEG'];
    I = imread(fullfile(mcg_root, 'demos1','video1',img_name));
    flow_name = [num,'.mat'];
    curr_flow = load(fullfile(mcg_root, 'demos1','flow',flow_name));
    curr_flow  = curr_flow.flow;
    [hier, ~] = get_hier(I, curr_flow);
    hier_name = [num,'.mat'];
    hier_name = fullfile(mcg_root, 'demos1','hier',hier_name);
    save(hier_name, 'hier');
end
