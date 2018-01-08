function scores = get_motion_scores(all_cand_sps, sp_flow_sum)
avg_overall_flow = sp_flow_sum(size(sp_flow_sum,1),1) / sp_flow_sum(size(sp_flow_sum,1),2); % 全局平均运动强度
avg_cand_flow = zeros(size(all_cand_sps,1),1);
for i = 1:size(all_cand_sps,1)
    cand_sps = all_cand_sps(i,:);
    cand_sps = cand_sps(cand_sps > 0);
    cand_flow_sum = sum(sp_flow_sum(cand_sps,1));
    cand_pixel_sum = sum(sp_flow_sum(cand_sps,2));
    avg_cand_flow(i) = cand_flow_sum / cand_pixel_sum;
end
avg_overall_flow_array = zeros(size(avg_cand_flow));
avg_overall_flow_array(:) = avg_overall_flow;
relative_flow = abs(avg_cand_flow - avg_overall_flow_array);
max_flow = max(relative_flow);
scores = relative_flow / max_flow;



