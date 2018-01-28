function scores = get_motion_scores(all_cand_sps, sp_flow_sum, cand_info, video_length)
image_pixel_sum = sp_flow_sum(size(sp_flow_sum,1),2);
avg_overall_flow = sp_flow_sum(size(sp_flow_sum,1),1) / image_pixel_sum; % overall_motion
avg_cand_flow = zeros(size(all_cand_sps,1),1);
% background_flow_sum = 0;
% background_pixel_sum = 0;
for i = 1:size(all_cand_sps,1)
    cand_sps = all_cand_sps(i,:);
    cand_sps = cand_sps(cand_sps > 0);
    cand_flow_sum = sum(sp_flow_sum(cand_sps,1));
    cand_pixel_sum = sum(sp_flow_sum(cand_sps,2));
    avg_cand_flow(i) = cand_flow_sum / cand_pixel_sum;
%     area_ratio = double(cand_pixel_sum) / double(image_pixel_sum);
%     if cand_info(i,6) == 1 && (cand_info(i,4) > (video_length * 0.8)) && (area_ratio < 0.5 && area_ratio > 0.2)
%         background_flow_sum = background_flow_sum + cand_flow_sum;
%         background_pixel_sum = background_pixel_sum + cand_pixel_sum;
%     end
end
% if background_pixel_sum > 0     % background detected
%     avg_overall_flow = double(background_flow_sum) / double(background_pixel_sum);
% end
avg_overall_flow_array = zeros(size(avg_cand_flow));
avg_overall_flow_array(:) = avg_overall_flow;
relative_flow = abs(avg_cand_flow - avg_overall_flow_array);
max_flow = max(relative_flow);
if sum(max_flow) > 0
    scores = relative_flow / max_flow;
else
    scores = zeros(size(all_cand_sps,1),1);
end



