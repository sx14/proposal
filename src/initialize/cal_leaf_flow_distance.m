function leaf_flow_distance = cal_leaf_flow_distance(flow, leaves_part)
label_sum = max(max(leaves_part));
avg_flow = zeros(1,label_sum,2);
    for j = 1:label_sum
        for k = 1:2 % 两个方向分别计算
          f = flow(:,:,k);
          leaf_f = f(leaves_part == j);
          avg_f = sum(leaf_f) / length(leaf_f);
          avg_flow(1,j,k) = avg_f;
        end
    end
    rep_flow = repmat(avg_flow,[size(avg_flow,2),1]);
    square_all_flow = zeros(size(rep_flow));
    for z = 1:2 % 两个方向分别计算
        f = rep_flow(:,:,z);
        diff = f - f';
        square = diff .* diff;
        square_all_flow(:,:,z) = square;
    end
    all_together_flow = sum(square_all_flow,3);
    leaf_flow_distance = all_together_flow .^ 0.5;