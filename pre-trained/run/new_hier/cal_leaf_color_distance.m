function leaf_color_distance = cal_leaf_color_distance(img, leaves_part, label_sum)
avg_color = zeros(1,label_sum,3);
    for j = 1:label_sum
        for k = 1:3 % 三个通道分别计算
          c = img(:,:,k);
          leaf = c(leaves_part == j);
          avg_c = sum(leaf) / length(leaf);
          avg_color(1,j,k) = avg_c;
        end
    end
    rep_color = repmat(avg_color,[size(avg_color,2),1]);
    square_all = zeros(size(rep_color));
    for z = 1:3 % 三个通道分别计算
        c = rep_color(:,:,z);
        diff = c - c';
        square = diff .* diff;
        square_all(:,:,z) = square;
    end
    all_together = sum(square_all,3);
    leaf_color_distance = all_together .^ 0.5;