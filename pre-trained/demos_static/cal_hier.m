imgs = dir(fullfile(mcg_root, 'demos2','video','*.jpg'));
% for i = 1:length(imgs)-1
for i = 1:10
    num=num2str(i,'%04d');
    img_name = [num,'.jpg'];
    I = imread(fullfile(mcg_root, 'demos2','video',img_name));
    flow_name = [num,'.mat'];
    curr_flow = load(fullfile(mcg_root, 'demos2','flow',flow_name));
    curr_flow  = curr_flow.flow;
    [hier, ~] = get_hier(I, curr_flow);
    hier_name = [num,'.mat'];
    hier_name = fullfile(mcg_root, 'demos2','hier',hier_name);
    save(hier_name, 'hier');
end