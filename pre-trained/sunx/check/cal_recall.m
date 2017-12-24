function [recall,smT_IoU,hit] = cal_recall(ground_truth_info, frame_annotations,hiers,cands,line_info,line_frame_sp_mat,org_width,org_height)
ground_truth_object_sum = size(ground_truth_info,1);
hit = zeros(ground_truth_object_sum,3); % 击中每个ground truth 的candidate id , T_IoU , avg_IoU
output_info = sprintf('candidate sum: %d object sum: %d', size(cands,1), size(ground_truth_info,1));
disp(output_info);
for j = 1:size(cands,1)         % 每一个候选轨迹
    output_info = sprintf('candidate id: %d', j);
    disp(output_info);
    for i = 1:ground_truth_object_sum   % 每一个标注出来的物体
        ground_start = ground_truth_info(i,2);
        ground_end = ground_truth_info(i,3);
        cand = cands(j,:);          % 候选轨迹
        cand_start = +inf;
        cand_end = 0;
        for k = 1:length(cand)
            line_label = cand(1,k);
            if line_label > 0
                line_start = line_info(line_label,2);
                line_end = line_info(line_label,3);
                cand_start = min(cand_start,line_start);
                cand_end = max(cand_end,line_end);
            end
        end
        % 并长 = 同时出现ground_truth 和 candidate 的帧数
        cand_length = cand_end - cand_start + 1;
        u_start  = min(ground_start,cand_start);
        u_end = max(ground_end, cand_end);
        u_length = u_end - u_start + 1;
        if cand_length / u_length < 0.5
            continue;
        end
        hit_frame_sum = 0;
        hit_IoU_sum = 0;
        for f = u_start:u_length % 每一帧，看是否击中??????这是不是u_end
            annotations = frame_annotations{f};
            if i > length(annotations)      % 当前帧上没有第i个object
                continue;
            end
            cand_sps = [];
            for k = 1:length(cand)  % 组成candidate的每一个串
                line = cand(1,k);
                if line ~= 0
                    sp = line_frame_sp_mat(line,f);
                    if sp ~= 0
                        cand_sps = cat(1,cand_sps,sp);
                    end
                end
            end
            if isempty(cand_sps)           % 当前帧上没有第j个candidate
                continue;
            end
            % 当前帧上既有object 又有 candidate，计算两个框的IoU看是否达标
            hier = hiers{f};
            annotation = annotations(i);
            if isempty(annotation.id)   % 该帧没有该物体
                continue;
            end
            resized_leaves_part = hier.leaves_part;
            sp_boxes = hier.sp_boxes;
            resized_long_edge = max(size(resized_leaves_part));
            org_long_edge = max(org_width,org_height);
            resize_ratio = org_long_edge / resized_long_edge;
            cand_sps_boxes = sp_boxes(cand_sps,:);
            all_max_x = cand_sps_boxes(:,1);
            all_min_x = cand_sps_boxes(:,2);
            all_max_y = cand_sps_boxes(:,3);
            all_min_y = cand_sps_boxes(:,4);
            cand_max_y = round(max(all_max_y) * resize_ratio);
            cand_min_y = round(min(all_min_y) * resize_ratio);
            cand_max_x = round(max(all_max_x) * resize_ratio);
            cand_min_x = round(min(all_min_x) * resize_ratio);
            ground_max_y = annotation.y_max;
            ground_min_y = annotation.y_min;
            ground_max_x = annotation.x_max;
            ground_min_x = annotation.x_min;
            cand_region = (cand_max_x - cand_min_x) * (cand_max_y - cand_min_y);
            ground_region = (ground_max_x - ground_min_x) * (ground_max_y - ground_min_y);
            intersection_r = min(cand_max_x,ground_max_x);
            intersection_l = max(cand_min_x,ground_min_x);
            intersection_t = max(cand_min_y,ground_min_y);
            intersection_b = min(cand_max_y,ground_max_y);
            intersection_width = intersection_r - intersection_l;
            intersection_height = intersection_b - intersection_t;
            if intersection_width > 0 && intersection_height > 0    % 两个框相交
                intersection_region = intersection_height * intersection_width;
                IoU = intersection_region / (cand_region + ground_region - intersection_region);
                if IoU >= 0.5
                    hit_frame_sum = hit_frame_sum + 1;
                    hit_IoU_sum = hit_IoU_sum + IoU;
                end
            end
        end
        T_IoU = hit_frame_sum / u_length;
        avg_IoU = hit_IoU_sum / hit_frame_sum;
        if hit(i,2) < T_IoU     % 更新最匹配的cand
            hit(i,1) = j;
            hit(i,2) = T_IoU;
            hit(i,3) = avg_IoU;
        elseif hit(i,2) == T_IoU && avg_IoU > hit(i,3)
            hit(i,1) = j;
            hit(i,2) = T_IoU;
            hit(i,3) = avg_IoU;
        end
    end
end
smT_IoU = sum(hit(:,2)) / ground_truth_object_sum;
recall = length(find(hit(:,2) > 0.5)) / ground_truth_object_sum;


function mask = get_binary_mask(sps, mask, hier, small_sp_sum)
for i = 1:length(sps)
    sp = sps(i);
    if sp > small_sp_sum    % 组合过的sp
        % 递归将sp包含的像素位置置1
        conbine = hier.ms_struct(sp-small_sp_sum);
        for j = 1:size(conbine.children,2)
            mask = get_binary_mask(conbine.children(1,j),mask,hier, small_sp_sum);
        end
    else    % 未组合过的sp
        % 直接置1
        sp_mask = hier.leaves_part == sp;
        mask(sp_mask) = 1;
    end
end
