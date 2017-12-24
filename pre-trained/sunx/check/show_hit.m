function show_hit(hiers,org_imgs,hit,cands,line_frame_sp_mat,ground_truth,org_height, org_width)
ground_sum = size(hit,1);
color_v = init_color(ground_sum);
% 要显示ground truth将show_ground_truth设为false;
show_ground_truth = true;

figure;
for f = 1:length(org_imgs)
    I = org_imgs{f};
    ratio = max(org_height,org_width) / max(size(I,1),size(I,2));
    I = imresize(I,[org_height,org_width]);
    hier = hiers{f};
    sp_boxes = hier.sp_boxes;
    line_sp = line_frame_sp_mat(:,f);
    annotations_on_frame = ground_truth{f};
    for h=1:size(annotations_on_frame,2)
        annotation = annotations_on_frame(h);
        if isempty(annotation.id)   % 第f帧上没有第h个标注物体
            continue;
        end
        % =========== 画 ground truth =========
        if show_ground_truth
            x_max = annotation.x_max;
            x_min = annotation.x_min;
            y_max = annotation.y_max;
            y_min = annotation.y_min;
            height = y_max - y_min;
            width = x_max - x_min;
            I = draw_rect(I,[x_min y_min],[width height],3,[255,255,255]);
        end
        % =========== 画 candidates ============
        cand = hit(h,1);
        max_T_IoU = hit(h,2);
%         if cand ~= 0 && max_T_IoU > 0.5
                    if cand ~= 0
            lines = cands(cand,:);
            sps = line_sp(lines(lines > 0));
            sps = sps(sps > 0);
            if isempty(sps)
                continue;
            end
            sps_boxes = sp_boxes(sps,:);
            x_max = round(max(sps_boxes(:,1)) * ratio);
            x_min = round(min(sps_boxes(:,2)) * ratio);
            y_max = round(max(sps_boxes(:,3)) * ratio);
            y_min = round(min(sps_boxes(:,4)) * ratio);
            height = y_max - y_min;
            width = x_max - x_min;
            I = draw_rect(I,[x_min y_min],[width height],3,color_v(h,:)');
        end
    end
    imshow(I),title(['frame: ',num2str(f)]);
    pause(0.2);
    %     input('next');
end
close;