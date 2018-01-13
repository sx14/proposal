function [line_bundle_cands,all_cand_info] = cal_line_bundle_cands(hier_set,sp_frame_line,all_line_info)
    proposal_max = 1000;
    cand_line_max = 10;
    frame_sum = length(hier_set);
    operate_pool = zeros(proposal_max*frame_sum,cand_line_max);
    all_cand_info = zeros(proposal_max*frame_sum,5);
    operate_pool_itr = 0;
    for f = 1:frame_sum             % each frame
        hier = hier_set{f};
        img_pros = hier.cands;
        for i = 1:size(img_pros,1)  % each img proposal
            img_pro_sps = img_pros(i,:);
            img_pro_sps = img_pro_sps(img_pro_sps > 0);
            [cand_lines,cand_info] = img_pro_2_cand_lines(img_pro_sps,sp_frame_line,f,all_line_info,cand_line_max);
            if sum(cand_lines) ~= 0 && ~ismember(cand_lines,operate_pool(1:operate_pool_itr,:),'rows')    % if curr cand is already in pool
                operate_pool_itr = operate_pool_itr + 1;
                operate_pool(operate_pool_itr,:) = cand_lines;
                cand_info(1) = operate_pool_itr;
                all_cand_info(operate_pool_itr,:) = cand_info;
            end
        end
    end
    line_bundle_cands = operate_pool(1:operate_pool_itr,:);
    all_cand_info = all_cand_info(1:operate_pool_itr,:);
end

function [cand_lines,cand_info] = img_pro_2_cand_lines(img_cand,sp_frame_line,frame,line_info,cand_line_max)
    min_line_length_ths = 5;
    cand_lines = sp_frame_line(img_cand,frame);
    cand_line_info = line_info(cand_lines,:);
    cand_line_info = cand_line_info(cand_line_info(:,4) >= min_line_length_ths,:);
    cand_lines = sort(cand_line_info(:,1),'ascend');
	cand_lines = [cand_lines;zeros(cand_line_max-length(cand_lines),1)]';
    cand_start_frame = min(cand_line_info(:,2));
    cand_end_frame = max(cand_line_info(:,3));
    cand_info = [0,cand_start_frame,cand_end_frame,(cand_end_frame - cand_start_frame),length(cand_lines)];
end