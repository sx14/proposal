function sp_flow_sum = get_sp_flow_sum(leaves, flow, conbine_mat)
leave_sum = max(max(leaves));
flow = sqrt(flow(:,:,1) .* flow(:,:,1) + flow(:,:,2) .* flow(:,:,2));
sp_flow_sum = zeros(leave_sum,1);
for r = 1:size(leaves,1)
    for c = 1:size(leaves,2)
        leave_label = leaves(r,c);
        sp_flow_sum(leave_label) = sp_flow_sum(leave_label) + flow(r,c);
    end
end
sp_flow_sum = conbine_mat * sp_flow_sum;

