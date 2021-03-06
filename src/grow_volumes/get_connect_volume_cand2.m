function volume_connect_mat = get_connect_volume_cand2(sp_boxes_set,volume_frame_sp_mat,volume_info,resized_imgs)
volume_interval_mat = get_volume_interval(volume_info,3);
volume_connect_mat = zeros(size(volume_interval_mat));
[first,second,~] = find(volume_interval_mat > 0);
for i = 1:length(first)
    first_volume = first(i);
    first_end_frame = volume_info(first_volume,3);
    first_volume_sp = volume_frame_sp_mat(first_volume, first_end_frame);
    first_sp_boxes = sp_boxes_set{first_end_frame};
    first_sp_box = first_sp_boxes(first_volume_sp,:);
    second_volume = second(i);
    second_start_frame = volume_info(second_volume,2);
    second_volume_sp = volume_frame_sp_mat(second_volume, second_start_frame);
    second_sp_boxes = sp_boxes_set{second_start_frame};
    second_sp_box = second_sp_boxes(second_volume_sp,:);
    left_top_pos = [first_sp_box(4),first_sp_box(2)];   % ymin,xmin
    box_height = first_sp_box(3) - first_sp_box(4);
    box_width = first_sp_box(1) - first_sp_box(2);
    box_sz = [box_height,box_width];
    if box_height >= 5 && box_width >= 5
        frames = cell(2,1);
        frames{1} = resized_imgs{first_end_frame};
        frames{2} = resized_imgs{second_start_frame};
        positions = run_tracker('my', frames, left_top_pos, box_sz);
        predict_position = positions(2,:);
    else
        predict_position = left_top_pos;
    end
    predict_second_sp_box = [predict_position(2) + box_width,predict_position(2),predict_position(1) + box_height,predict_position(1)];
    iou = cal_box_IoU(second_sp_box,predict_second_sp_box);
    if iou > 0.6
        volume_connect_mat(first_volume,second_volume) = iou;
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