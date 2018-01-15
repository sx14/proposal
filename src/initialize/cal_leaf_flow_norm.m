function leaf_flow_norm = cal_leaf_flow_norm(leaves_part,flow)
leaf_sum = max(max(leaves_part));
leaf_flow_norm = zeros(leaf_sum,2);
flow_norm = (flow(:,:,1) .^ 2 + flow(:,:,2) .^ 2) .^ 0.5;
for i = 1:size(leaves_part,1)
    for j = 1:size(leaves_part,2)
        leaf = leaves_part(i,j);
        leaf_flow_norm(leaf,1) = leaf_flow_norm(leaf,1) + flow_norm(i,j);
        leaf_flow_norm(leaf,2) = leaf_flow_norm(leaf,2) + 1;
    end
end
leaf_flow_norm = leaf_flow_norm(:,1) ./ leaf_flow_norm(:,2);