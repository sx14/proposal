% 持久化所有的层次结构
function hier_set = cal_hier(video_package_path,video_dir,mid_result_path,flow_set,resized_imgs, re_cal)
hier_dir_name = 'hier';
video_path = fullfile(video_package_path,video_dir);
video_hier_path = fullfile(mid_result_path,hier_dir_name,video_dir);
if ~exist(video_hier_path,'dir')
    mkdir(fullfile(mid_result_path,hier_dir_name), video_dir);
end
hier_set = cell(length(resized_imgs),1);
if ~exist(fullfile(video_hier_path,'finish'),'file') || re_cal == 1  % cal
    start_one = 0;
    last_one = length(resized_imgs) - 1;
    for i = start_one:last_one
        num=num2str(i,'%06d');
        I = resized_imgs{i+1};
        curr_flow = flow_set{i+1};
        [hier, ~] = get_hier(I, curr_flow);
        hier_set{i+1,1} = hier;
        hier_name = [num,'.mat'];
        hier_name = fullfile(video_hier_path,hier_name);
        save(hier_name, 'hier');
    end
    cal_finish(video_hier_path);
    disp('cal_hier finished.');
else
    start_one = 0;
    last_one = length(resized_imgs) - 1;
    for i = start_one:last_one
        num=num2str(i,'%06d');
        hier_name = [num,'.mat'];
        hier_path = fullfile(video_hier_path, hier_name);
        heir_file = load(hier_path);
        hier = heir_file.hier;
        % ==== top leaves ====
        [new_leaves,new_to_org] = get_top_level(hier);
        hier.org_leaves_part = hier.leaves_part;
        hier.leaves_part = new_leaves;
        hier.new_to_org = new_to_org;
        hier.org_ms_matrix = hier.ms_matrix;
        hier.ms_matrix = zeros(0,3);
        % ==== top leaves ====
        hier_set{i+1} = hier;
    end
    disp('cal_hier finished before.');
end


function [new_leaves,new_to_org] = get_top_level(hier)
leaves = hier.leaves_part;
ms_matrix = hier.ms_matrix;
org_leaf_sum = max(max(leaves));
org_sp_sum = org_leaf_sum + size(hier.ms_matrix,1);
top_level_sp_sum = floor(org_leaf_sum * 0.3);
curr_leaf_sum = org_leaf_sum;
for i = 1:(org_sp_sum - org_leaf_sum)
    if curr_leaf_sum == top_level_sp_sum
        break;
    end
    combine = ms_matrix(i,:);
    parent = combine(end);
    chidren = combine(1:end-1);
    mask = ismember(leaves,chidren);
    leaves(mask) = parent;
    curr_leaf_sum = curr_leaf_sum - 1;
end
new_to_org = zeros(curr_leaf_sum,1);
org_to_new = zeros(max(max(leaves)),1);
next_leaf_label = 1;
for i = 1:size(leaves,1)
    for j = 1:size(leaves,2)
        org_leaf = leaves(i,j);
        new_leaf = org_to_new(org_leaf);
        if  new_leaf == 0   % new leaf
            org_to_new(org_leaf) = next_leaf_label;
            new_to_org(next_leaf_label) = org_leaf;
            leaves(i,j) = next_leaf_label;
            next_leaf_label = next_leaf_label + 1;
        else                % new leaf existed 
            leaves(i,j) = new_leaf;
        end
    end
end
new_leaves = leaves;
