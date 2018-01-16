function avg_scores = get_cand_scores(hiers, cands, line_frame_sp_mat, cand_info, sp_flow_info_set)
rf_regressor = loadvar(fullfile(root,'mcg', 'datasets', 'models', 'scg_rand_forest_train2012.mat'),'rf');
scores = zeros(size(cands,1),length(hiers));
for f = 1:length(hiers)
    hier = hiers{f};
    f_lp = hier.leaves_part;
    leave_sum = max(max(f_lp));
    zero_col_num = size(hier.ms_matrix,2) - 2;
    leaves_ms = [(1:leave_sum)',zeros(leave_sum,zero_col_num),((1:leave_sum)+leave_sum)'];
    temp_ms = hier.ms_matrix;
    temp_ms(temp_ms > 0) = temp_ms(temp_ms > 0) + double(leave_sum);
    f_ms = cat(1,leaves_ms,temp_ms);
    if isfield(hier,'b_feats')
        b_feats = hier.b_feats;
    else
        ucm = hier.ucm;
        b_feats = compute_base_features(f_lp, f_ms, ucm);
        b_feats.start_ths = [zeros(leave_sum,1);hier.start_ths]';
        b_feats.end_ths   = [zeros(leave_sum,1);hier.end_ths]';
        b_feats.im_size   = size(f_lp);
    end
    
    [sp_cand,indexes] = get_sp_cand(cands,line_frame_sp_mat,f);
    sp_cand(sp_cand > 0) = sp_cand(sp_cand > 0) + double(leave_sum);
    if ~isempty(f_ms)
        [cands_hf, ~] = hole_filling(double(f_lp), double(f_ms), sp_cand);
    else
        cands_hf = sp_cand;
    end
    [feats, bboxes] = compute_full_features(cands_hf,b_feats);
    sp_flow_info = sp_flow_info_set{f};
    cands_hf(cands_hf > 0) = cands_hf(cands_hf > 0) - double(leave_sum);
    motion_cand_scores = get_motion_scores(cands_hf, sp_flow_info);
    frame_cand_scores = regRF_predict(feats,rf_regressor);
    scores(indexes,f) = frame_cand_scores * 0.7 + motion_cand_scores * 0.3;
end

scores = sort(scores,2,'descend');
avg_scores = zeros(size(cand_info,1),1);
% long_line_length_ths = floor(length(hiers) * 0.8);
% long_line_ths_array = zeros(size(avg_scores));
% long_line_ths_array(:) = long_line_length_ths;
% [top_k,~] = min([cand_info(:,4) long_line_ths_array],[],2);
top_k = floor(cand_info(:,4) * 0.9);
for i = 1:size(scores,1)
    score_sum = sum(scores(i,1:top_k(i)));
    avg_scores(i) = score_sum / top_k(i);
end


% avg_scores = zeros(size(cand_info,1),1);
% for i = 1:size(cand_info,1)
%     c_length = cand_info(i,4);
%     weights = zeros(c_length,1);
%     mid = floor((c_length + 1) / 2);
%     weights(1:mid,1) = mid;
%     if mod(c_length,2) == 0
%         weights(mid+1:end,1) = mid - 1 : -1 : 0;
%     else
%         weights(mid:end,1) = mid - 1 : -1 : 0;
%     end
%     cand_scores = scores(i,1:c_length);
%     s = sum(cand_scores' .* weights) / sum(weights);
%     avg_scores(i,1) = s;
% end

% avg_scores = sum(scores,2) ./ cand_info(:,4);



function [sp_cand,indexes] = get_sp_cand(cands,line_frame_sp_mat,frame)
sp_cand = zeros(size(cands));
indexes = zeros(size(cands,1),1);
counter = 0;
all_sps_on_frame = line_frame_sp_mat(:,frame);
for i = 1:size(cands,1)
    lines = cands(i,:);
    lines = lines(lines > 0);    % candidate 包含的串号
    line_sps = all_sps_on_frame(lines);
    line_sps = line_sps(line_sps > 0);
    if ~isempty(line_sps)
        counter = counter + 1;
        sp_cand(counter,1:length(line_sps)) = line_sps;
        indexes(counter) = i;
    end
end
sp_cand = sp_cand(1:counter,:);
indexes = indexes(1:counter,:);