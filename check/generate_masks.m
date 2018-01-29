function generate_masks(output_path,video_dir,result,proposals,selected_cands,sp_leaves_set,hier_set,resized_imgs,line_frame_sp_mat)
hit_proposal_id_list = zeros(100,1);
hit = result.hit;
next = 0;
for i = 1:size(hit,1)
    for h = 1:size(hit,2)
        if hit(i,h,2) > 0
            if sum(hit_proposal_id_list == hit(i,h,1)) == 0
                next = next + 1;
                hit_proposal_id_list(next) = hit(i,h,1);
            end
        end
    end
end

for h = 1:size(hit_proposal_id_list,1)
    proposal_id = hit_proposal_id_list(h);
    if proposal_id > 0
        generate_proposal_masks(output_path,video_dir,proposal_id,proposals{proposal_id},selected_cands,sp_leaves_set,hier_set,resized_imgs,line_frame_sp_mat);
    end
end
end

function generate_proposal_masks(output_path,video_dir,proposal_id,proposal,selected_cands,sp_leaves_set,hier_set,resized_imgs,line_frame_sp_mat)
start_frame = proposal.start_frame;
end_frame = proposal.end_frame;
cand_lines = selected_cands(proposal_id,:);
cand_lines = cand_lines(cand_lines > 0);
for f = start_frame:end_frame
    o_cand_sps = line_frame_sp_mat(cand_lines,f);
    cand_sps = o_cand_sps(o_cand_sps > 0);
    if isempty(cand_sps)
        continue;
    end
    mask = zeros(size(hier_set{f}.leaves_part));
    sp_leaves_mat = sp_leaves_set{f};
    for c = 1:length(o_cand_sps)
        if o_cand_sps(c) > 0
            leaves = sp_leaves_mat(o_cand_sps(c),:);
            leaves = unique(leaves(leaves > 0));
            mask_b = ismember(hier_set{f}.leaves_part,leaves);
            mask(mask_b) = c;
        end
    end
    color_set = get_color_set();
    org_img = resized_imgs{f};
%     white_mask = zeros(size(org_img));
%     white_mask(:,:,:) = 255;
%     org_img = 0.5*double(org_img) + 0.5*double(white_mask);
    masked_img = color_mask(org_img, mask, color_set);
    save_mask(output_path,video_dir,f-1,proposal_id,masked_img);
end
end

function color_set = get_color_set()
color_set = [
    255,0,0     ;        % r
    0,0,255  ;        % b
    0,255,0     ;        % g
    255,0,255   ;        % m
    ];
end

function save_mask(output_path,video_dir,frame,proposal_id,masked_img)
mask_dir = 'hit';
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
imwrite(masked_img,bmp_file_name);
end

function masked_img = color_mask(org_img, mask_b, color_set)
% masked_img = org_img;
masked_img = zeros(size(org_img));
masked_img(:,:,:) = 150;
% org_img(:,:,:) = org_img(:,:,:) + 100;
for v = min(min(mask_b)) : max(max(mask_b))
    if v ~= 0
%         if v == 3
%             continue;
%         end
        mask_temp = (mask_b == v);
        org_r = masked_img(:,:,1);
        org_g = masked_img(:,:,2);
        org_b = masked_img(:,:,3);
        org_r(mask_temp) = color_set(v,1);
        org_g(mask_temp) = color_set(v,2);
        org_b(mask_temp) = color_set(v,3);
        masked_img(:,:,1) = org_r;
        masked_img(:,:,2) = org_g;
        masked_img(:,:,3) = org_b;
    end
end
masked_img = round(0.7*double(masked_img) + 0.3*double(org_img));
masked_img = uint8(masked_img);
end