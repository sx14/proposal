function match = get_match(last_flow, last_leaves, last_sp_pixel_mat, new_leaves)
match = zeros(max(max(last_leaves)),max(max(new_leaves)));
last_round_flow = round(last_flow);
% r:last;c:new
% 元素表示：last第r个超像素落在new第c个超像素的像素个数占last第r个超像素的像素个数的比例
for i = 1:size(last_flow,1)
    for j = 1:size(last_flow,2)
        last_label = last_leaves(i,j);
        match_x = i + last_round_flow(i,j,2);   % 竖直方向
        match_y = j + last_round_flow(i,j,1);   % 水平方向
        if match_x > 0 && match_x <= size(new_leaves,1) && match_y > 0 && match_y <= size(new_leaves,2)
            match_label = new_leaves(match_x,match_y);
            match(last_label,match_label) = match(last_label,match_label) + 1;
        end
    end
end

for c = 1:size(match,2)
    match(:,c) = match(:,c)./last_sp_pixel_mat(:,2);
end