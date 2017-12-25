function avg_scores = get_cand_scores(hiers, cands, line_frame_sp_mat, cand_info)
rf_regressor = loadvar(fullfile(mcg_root, 'datasets', 'models', 'scg_rand_forest_train2012.mat'),'rf');
scores = zeros(size(cands,1),length(hiers));
for f = 1:length(hiers)
    hier = hiers{f};
    f_lp = hier.leaves_part;
    leave_sum = max(max(f_lp));
    leaves_ms = [(1:leave_sum)',zeros(leave_sum,1),(1:leave_sum)'];
    f_ms = cat(1,leaves_ms,hier.ms_matrix);
    ucm = hier.ucm;
    b_feats = compute_base_features(f_lp, f_ms, ucm);
    b_feats.start_ths = hier.start_ths;
    b_feats.end_ths   = hier.end_ths;
    b_feats.im_size   = size(f_lp);
    sp_cand = get_sp_cand(cands,line_frame_sp_mat,f);
    [feats, bboxes] = compute_full_features(sp_cand,b_feats);
    frame_cand_scores = regRF_predict(feats,rf_regressor);
    scores(:,f) = frame_cand_scores;
end
scores = sort(scores,2,'descend');
top_k = floor(length(hiers) * 0.2);
temp = scores(:,1:top_k);
temp1 = sum(scores(:,1:top_k),2);
avg_scores = sum(scores(:,1:top_k),2) / top_k;
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



function sp_cand = get_sp_cand(cands,line_frame_sp_mat,frame)
sp_cand = zeros(size(cands));
all_sps_on_frame = line_frame_sp_mat(:,frame);
for i = 1:size(cands,1)
    lines = cands(i,:);
    lines = lines(lines > 0);    % candidate 包含的串号
    line_sps = all_sps_on_frame(lines);
    line_sps = line_sps(line_sps > 0);
    sp_cand(i,1:length(line_sps)) = line_sps;
end