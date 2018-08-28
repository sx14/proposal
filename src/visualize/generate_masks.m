function generate_masks(output_path,video_dir,result,proposals,mask_generation_package, only_hitted)
fprintf('generating masks ... ');
if only_hitted == 1
    mask_dir = 'hitted_mask';
else
    mask_dir = 'proposal_mask';
end
if ~exist(fullfile(output_path, mask_dir),'dir')
    mkdir(fullfile(output_path), mask_dir);
end
if exist(fullfile(output_path, mask_dir,video_dir),'dir')
    rmdir(fullfile(output_path, mask_dir, video_dir), 's');
end
mkdir(fullfile(output_path,mask_dir),video_dir);
output_path = fullfile(output_path,mask_dir,video_dir);
selected_cands = mask_generation_package.proposal_volume_group;
sp_leaves_set = mask_generation_package.sp_leaves_set;
hier_set = mask_generation_package.hier_set;
resized_imgs = mask_generation_package.resized_imgs;
volume_frame_sp_mat = mask_generation_package.volume_frame_sp_mat;
if only_hitted == 1
    hit = result.hit;
    hit_proposal_id_list = zeros(length(hit(1,:,1)),1);
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
else
    hit_proposal_id_list = (1:100)';
end
for h = 1:size(hit_proposal_id_list,1)
    proposal_id = hit_proposal_id_list(h);
    if proposal_id > 0
        generate_proposal_masks(output_path,proposal_id,proposals{proposal_id},selected_cands,sp_leaves_set,hier_set,resized_imgs,volume_frame_sp_mat);
    end
end
fprintf('finish\n');
end


function generate_proposal_masks(output_path,proposal_id,proposal,selected_cands,sp_leaves_set,hier_set,resized_imgs,volume_frame_sp_mat)
start_frame = proposal.start_frame;
end_frame = proposal.end_frame;
cand_volumes = selected_cands(proposal_id,:);
cand_volumes = cand_volumes(cand_volumes > 0);
color_set = get_color_set();
for f = start_frame:end_frame
    cand_sps = volume_frame_sp_mat(cand_volumes,f);
    mask = zeros(size(hier_set{f}.leaves_part));
    sp_leaves_mat = sp_leaves_set{f};
    for c = 1:length(cand_sps)
        if cand_sps(c) == 0
            continue;
        end
        leaves = sp_leaves_mat(cand_sps(c),:);
        leaves = unique(leaves(leaves > 0));
        mask_b = ismember(hier_set{f}.leaves_part,leaves);
        mask(mask_b) = c;
    end
    org_img = resized_imgs{f};
    white_mask = zeros(size(org_img));
    white_mask(:,:,:) = 255;
    org_img = 0.5*double(org_img) + 0.5*double(white_mask);
    masked_img = color_mask(org_img, mask, color_set);
    save_mask(output_path,f-1,proposal_id,masked_img);
end
end

function color_set = get_color_set()
color_set = [
    255,0,0     ;        % r
    0,0,255  ;           % b
    0,255,0     ;        % g
    255,0,255   ;        % m
    255,255,0   ;        % m
    0,255,255   ;        % m
    ];
end

function save_mask(output_path,frame,proposal_id,masked_img)
p_num=num2str(proposal_id,'%04d');
if ~exist(fullfile(output_path,p_num),'dir')
    mkdir(output_path,p_num);
end
f_num=num2str(frame,'%06d');
bmp_file_name = fullfile(output_path,p_num,[f_num,'.JPEG']);
imwrite(masked_img,bmp_file_name);
end

function masked_img = color_mask(org_img, mask, color_set)
masked_img = org_img;
for v = min(min(mask)) : max(max(mask))
    if v ~= 0
        mask_temp = (mask == v);
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