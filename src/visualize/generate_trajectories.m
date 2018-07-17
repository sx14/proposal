function generate_trajectories(output_path, video_dir, org_imgs,all_hit,proposals,ground_truth,org_height, org_width)
ground_sum = size(all_hit,1);
color_v = init_color(ground_sum);
% 要显示ground truth将show_ground_truth设为false;
show_ground_truth = false;
figure;
for f = 1:length(org_imgs)
    I = org_imgs{f};
    [resized_height,resized_width] = size(I(:,:,1));
    resize_ratio = double(org_height)/double(resized_height);
%     I = imresize(I,[org_height,org_width]);
    annotations_on_frame = ground_truth{f};
    for h = ground_sum:-1:1
        annotation = annotations_on_frame(h);
        hit = all_hit(h,size(all_hit,2),:);
        if ~isempty(annotation.id)   % 第f帧上没有第h个标注物体
            % =========== 画 ground truth =========
            if show_ground_truth
                x_max = annotation.x_max;
                x_min = annotation.x_min;
                y_max = annotation.y_max;
                y_min = annotation.y_min;
                % ========= resize gt ==========
                x_max = min(floor(x_max / resize_ratio),resized_width);
                x_min = max(floor(x_min / resize_ratio),1);
                y_max = min(floor(y_max / resize_ratio),resized_height);
                y_min = max(floor(y_min / resize_ratio),1);
                % ========= resize gt ==========
                height = y_max - y_min;
                width = x_max - x_min;
                I = draw_rect(I,[x_min y_min],[width height],5,[255,255,255]);
            end
        end
        % =========== 画 candidates ============
        proposal_id = hit(1);
        max_T_IoU = hit(2);
        if proposal_id ~= 0 && max_T_IoU > 0.4
            proposal = proposals{proposal_id};
            boxes = proposal.boxes;
            box = boxes(f,:);
            if sum(box) > 0
                x_max = box(1);
                x_min = box(2);
                y_max = box(3);
                y_min = box(4);
                % ========= resize pro ==========
                x_max = floor(min(x_max / resize_ratio,resized_width));
                x_min = floor(max(x_min / resize_ratio,1));
                y_max = floor(min(y_max / resize_ratio,resized_height));
                y_min = floor(max(y_min / resize_ratio,1));
                % ========= resize pro ==========
                height = y_max - y_min;
                width = x_max - x_min;
                height = max(height,5);
                width = max(width,5);
                
%                 if isempty(annotation.id)
%                     I = draw_rect(I,[x_min y_min],[width height],4,color_v(h,:)');
%                     continue;
%                 end
%                 
%                 a_x_max = min(floor(annotation.x_max / resize_ratio),resized_width);
%                 a_x_min = max(floor(annotation.x_min / resize_ratio),1);
%                 a_y_max = min(floor(annotation.y_max / resize_ratio),resized_height);
%                 a_y_min = max(floor(annotation.y_min / resize_ratio),1);
%                 intersection_r = min(x_max,a_x_max);
%                 intersection_l = max(x_min,a_x_min);
%                 intersection_t = max(y_min,a_y_min);
%                 intersection_b = min(y_max,a_y_max);
%                 intersection_width = intersection_r - intersection_l;
%                 intersection_height = intersection_b - intersection_t;
% 
%                 if intersection_width > 0 && intersection_height > 0    % 两个框相交
%                     cand_region = (x_max - x_min) * (y_max - y_min);
%                     ground_region = (a_x_max - a_x_min) * (a_y_max - a_y_min);
%                     intersection_region = intersection_height * intersection_width;
%                     IoU = intersection_region / (cand_region + ground_region - intersection_region);
%                     if IoU > 0.3   % 命中单帧
%                         I = draw_rect(I,[x_min y_min],[width height],4,color_v(h,:)');
%                     end
%                 end
                
                I = draw_rect(I,[x_min y_min],[width height],4,color_v(h,:)');
            end
        end
    end
    imshow(I),title(['frame: ',num2str(f)]);
    num1=num2str(f-1,'%06d');
    frame_name = [num1,'.JPEG'];
    output_dir = 'trajectory';
    if ~exist(fullfile(output_path, output_dir),'dir')
        mkdir(fullfile(output_path), output_dir); % make proposals dir
    end
    if ~exist(fullfile(output_path, output_dir,video_dir),'dir')
        mkdir(fullfile(output_path,output_dir),video_dir); % make proposals dir
    end
    imwrite(I,fullfile(output_path,output_dir,video_dir,frame_name));
end
close;