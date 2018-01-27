function proposals = cands_to_proposals(hiers,cands,sp_boxes_set,sp_flow_info_set,sp_leaves_set,line_frame_sp_mat,cand_info,output_path,video_dir,resized_imgs)
all_scores = get_cand_scores(hiers, cands, line_frame_sp_mat,cand_info,sp_flow_info_set);
one_two_sum = length(find(cand_info(:,5) < 3));
scores_part1 = all_scores(1:one_two_sum);
scores_part2 = all_scores(one_two_sum+1:end);
scores = [scores_part1;scores_part2];
[~,ids1] = sort(scores_part1,'descend');
[~,ids2] = sort(scores_part2,'descend');
ids2 = ids2 + one_two_sum;
one_two_cand_top_sum = floor(0.8*one_two_sum);      % 一二组合取前80%
one_two_cand_sum = min(one_two_cand_top_sum,300);   % 不多于300
ids1 = ids1(1:one_two_cand_sum);
ids = [ids1;ids2];
last_one = min(size(ids,1),1000);                   % proposal sum
selected_cands = cands(ids(1:last_one),:);          % sorted cands
selected_cand_scores = scores(ids(1:last_one));
% ======== no score ========
% last_one = size(cands,1);
% ids = 1:last_one;
% selected_cands = cands;
% selected_cand_scores = zeros(size(cands,1),1);
% ======== no score ========
figure;
proposals = cell(last_one,1);
proposal_info = cand_info(ids(1:last_one),:);
color_set = get_color_set();
for i = 1:last_one      % generate boxes for each proposal
    cand_lines = selected_cands(i,:);
    cand_lines = cand_lines(cand_lines > 0);
    start_frame = proposal_info(i,2);
    end_frame = proposal_info(i,3);
    boxes = zeros(length(hiers),4);
    for f = start_frame:end_frame        
        o_cand_sps = line_frame_sp_mat(cand_lines,f);
        cand_sps = o_cand_sps(o_cand_sps > 0);
        if isempty(cand_sps)
            continue;
        end
        % === mask ===
        mask = zeros(size(hiers{f}.leaves_part));
        sp_leaves_mat = sp_leaves_set{f};
        for c = 1:length(o_cand_sps)
            if o_cand_sps(c) > 0
                leaves = sp_leaves_mat(o_cand_sps(c),:);
                leaves = unique(leaves(leaves > 0));
                mask_b = ismember(hiers{f}.leaves_part,leaves);
                mask(mask_b) = c;
            end
        end
        masked_img = color_mask(resized_imgs{f}, mask, color_set);
        save_mask(output_path,video_dir,f-1,i,masked_img);
        % === mask ===
        sp_boxes = sp_boxes_set{f};
        cand_sps_boxes = sp_boxes(cand_sps,:);
        all_max_x = cand_sps_boxes(:,1);
        all_min_x = cand_sps_boxes(:,2);
        all_max_y = cand_sps_boxes(:,3);
        all_min_y = cand_sps_boxes(:,4);
        cand_max_x = max(all_max_x);
        cand_min_x = min(all_min_x);
        cand_max_y = max(all_max_y);
        cand_min_y = min(all_min_y);
        boxes(f,:) = [cand_max_x,cand_min_x,cand_max_y,cand_min_y];
    end
    proposal.voxel_num = cand_info(ids(i),5);
    proposal.start_frame = start_frame;
    proposal.end_frame = end_frame;
    proposal.boxes = boxes;
    proposal.video = video_dir;
    proposal.score = selected_cand_scores(i);
    proposals{i} = proposal;
end
close all;
% =========== connect short proposals ============
% proposals_part1 = proposals(1:one_two_sum);
% proposals_part2 = proposals(one_two_sum+1:end);
% proposals_part2_info = proposal_info(one_two_sum+1:end,:);
% connect_proposal_cands = get_connect_proposal_cand(proposals_part2,proposals_part2_info,resized_imgs);
% proposals_part2 = connect_proposals(proposals,connect_proposal_cands,length(hiers),1000-one_two_sum);
% proposals = [proposals_part1,proposals_part2];
end


function save_mask(output_path,video_dir,frame,proposal_id,masked_img)
mask_dir = 'mask';
if ~exist(fullfile(output_path, mask_dir),'dir')
    mkdir(fullfile(output_path), mask_dir); % make proposals dir
end
if ~exist(fullfile(output_path, mask_dir,video_dir),'dir')
    mkdir(fullfile(output_path,mask_dir),video_dir); % make proposals dir
end
p_num=num2str(proposal_id,'%04d');
if ~exist(fullfile(output_path, mask_dir,video_dir,p_num),'dir')
    mkdir(fullfile(output_path,mask_dir,video_dir),p_num);
end
f_num=num2str(frame,'%06d');
bmp_file_name = fullfile(output_path,mask_dir,video_dir,p_num,[f_num,'.jpeg']);
% f=getframe(gcf);
% imwrite(f.cdata,bmp_file_name)
imwrite(masked_img,bmp_file_name);
end

function masked_img = color_mask(org_img, mask_b, color_set)
% img_handler = figure('visible','off');
% img_handler = figure;
masked_img = org_img;
for c = min(min(mask_b)) : max(max(mask_b))
    if c ~= 0
        mask_temp = (mask_b == c);
        org_r = masked_img(:,:,1);
        org_g = masked_img(:,:,2);
        org_b = masked_img(:,:,3);
        org_r(mask_temp) = color_set(c,1);
        org_g(mask_temp) = color_set(c,2);
        org_b(mask_temp) = color_set(c,3);
        masked_img(:,:,1) = org_r;
        masked_img(:,:,2) = org_g;
        masked_img(:,:,3) = org_b;
    end
end
masked_img = round(0.7*masked_img + 0.3*org_img);
masked_img = uint8(masked_img);
% imshow(org_img),hold on;
% h = imshow(masked_img);
% set(h,'alphaData',0.5);
end

function color_set = get_color_set()
color_set = [
    240,110,77;     % r
    191,249,83;     % g
    169,209,236;    % b
    252,213,61;     % y
    ];
end