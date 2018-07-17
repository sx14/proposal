function proposals = get_connect_proposal_cand(proposals,cand_info,resized_imgs)
cand_interval_ths = 3;
cand_interval_mat = get_line_interval(cand_info,cand_interval_ths);
cand_connect_mat = zeros(size(cand_interval_mat));
[first,second,~] = find(cand_interval_mat > 0);
predict_boxes = zeros(size(cand_interval_mat,1),3,4);
predict_done = zeros(size(cand_interval_mat,1),1);
for i = 1:length(first)
    first_cand = first(i);
    if predict_done(first_cand) == 0    % haven't tracked
        first_end_frame = cand_info(first_cand,3);
        first_sp_box = proposals{first_cand}.boxes(first_end_frame,:);
        left_top_pos = [first_sp_box(4),first_sp_box(2)];   % ymin,xmin
        box_height = first_sp_box(3) - first_sp_box(4);
        box_width = first_sp_box(1) - first_sp_box(2);
        box_sz = [box_height,box_width];
        if box_height >= 5 && box_width >= 5
            expected_start_frame = first_end_frame + cand_interval_ths;
            frames = resized_imgs{first_end_frame:expected_start_frame};
            positions = run_tracker('my', frames, left_top_pos, box_sz);
            predict_position = positions(2:end,:);
        else
            predict_position = repmat(left_top_pos,cand_interval_ths,1);
        end
        predict_second_boxes = [predict_position(:,2) + box_width,predict_position(:,2),predict_position(:,1) + box_height,predict_position(:,1)];
        predict_boxes(first_cand,:,:) = predict_second_boxes;
        predict_done(first_cand) = 1;
    end
    second_cand = second(i);
    second_start_frame = cand_info(second_cand,2);
    second_cand_box = proposals{second_cand}.boxes(second_start_frame,:);
    first2second_interval = cand_interval_mat(first_cand,second_cand);
    predict_second_cand_box = predict_boxes(first_cand,first2second_interval,:);
    iou = cal_box_IoU(second_cand_box,predict_second_cand_box);
    if iou > 0.6
        cand_connect_mat(first_line,second_line) = iou;
    end
end



function iou = cal_box_IoU(box1,box2)
right = min(box1(1),box2(1));
left = max(box1(2),box2(2));
bottom = min(box1(3),box2(3));
top = max(box1(4),box2(4));
intersection_box_width = right - left;
intersection_box_height = bottom - top;
if intersection_box_width > 0 && intersection_box_height > 0
    intersection_area = intersection_box_width * intersection_box_height;
    box1_area = (box1(1) - box1(2)) * (box1(3) - box1(4));
    box2_area = (box2(1) - box2(2)) * (box2(3) - box2(4));
    iou = intersection_area / (box1_area + box2_area - intersection_area);
else  
    iou = 0;
end