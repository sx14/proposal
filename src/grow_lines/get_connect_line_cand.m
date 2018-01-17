function line_connect_mat = connect_lines(sp_boxes_set, sp_lab_hist_set, line_frame_sp_mat,line_info)
line_interval_mat = get_line_interval(line_info,3);
line_space_distance_mat = zeros(size(line_interval_mat));
line_color_distance_mat = zeros(size(line_interval_mat));
line_area_ratio_mat = zeros(size(line_interval_mat));
[first,second,~] = find(line_interval_mat > 0);
for i = 1:length(first)
    first_line = first(i);
    first_end_frame = line_info(first_line,3);
    first_line_sp = line_frame_sp_mat(first_line, first_end_frame);
    first_frame_lab_hist = sp_lab_hist_set{first_end_frame};
    first_sp_lab_hist = first_frame_lab_hist(first_line_sp,:);
    first_sp_boxes = sp_boxes_set{first_end_frame}.sp_boxes;
    first_sp_box = first_sp_boxes(first_line_sp,:);
    second_line = second(i);
    second_start_frame = line_info(second_line,2);
    second_line_sp = line_frame_sp_mat(second_line, second_start_frame);
    second_frame_lab_hist = sp_lab_hist_set{second_start_frame};
    second_sp_lab_hist = second_frame_lab_hist(second_line_sp,:);
    second_sp_boxes = sp_boxes_set{second_start_frame}.sp_boxes;
    second_sp_box = second_sp_boxes(second_line_sp,:);
    line_color_distance_mat(first_line, second_line) = cal_lab_color_distance(first_sp_lab_hist, second_sp_lab_hist);
    line_space_distance_mat(first_line, second_line) = cal_space_distance(first_sp_box, second_sp_box);
    line_area_ratio_mat(first_line, second_line) = cal_area_ratio(first_sp_box,second_sp_box);
end
line_color_distance_mat(line_color_distance_mat > 0.5) = 0;
line_color_distance_mat = line_color_distance_mat & line_color_distance_mat;
line_space_distance_mat(line_space_distance_mat > 20) = 0;
line_space_distance_mat = line_space_distance_mat & line_space_distance_mat;
line_area_ratio_mat(line_area_ratio_mat > 2) = 0;
line_area_ratio_mat = line_area_ratio_mat & line_area_ratio_mat;
line_connect_mat = line_interval_mat & line_area_ratio_mat & line_space_distance_mat & line_color_distance_mat;


function color_distance = cal_lab_color_distance(color1, color2)
diff = color1 - color2;
square = diff .* diff;
color_distance = sqrt(sum(square));

function space_distance = cal_space_distance(box1, box2)
mid_x_1 = floor((box1(1) + box1(2)) / 2);
mid_y_1 = floor((box1(3) + box1(4)) / 2);
mid_x_2 = floor((box2(1) + box2(2)) / 2);
mid_y_2 = floor((box2(3) + box2(4)) / 2);
mid_1 = [mid_x_1 , mid_y_1];
mid_2 = [mid_x_2 , mid_y_2];
diff = mid_1 - mid_2;
square = diff .* diff;
space_distance = sqrt(sum(square));

function area_ratio = cal_area_ratio(box1,box2)
area1 = (box1(1) - box1(2)) * (box1(3) - box1(4));
area2 = (box2(1) - box2(2)) * (box2(3) - box2(4));
area_ratio = max(area1,area2) / min(area1,area2);