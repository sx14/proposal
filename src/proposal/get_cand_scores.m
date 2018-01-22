function avg_scores = get_cand_scores(hiers, cands, line_frame_sp_mat, cand_info, sp_flow_info_set)
rf_regressor = loadvar(fullfile(root,'mcg', 'datasets', 'models', 'scg_rand_forest_train2012.mat'),'rf');
scores = zeros(size(cands,1),length(hiers));
for f = 1:length(hiers)
    hier = hiers{f};
    f_lp = hier.org_leaves_part;
    leave_sum = max(max(f_lp));
    zero_col_num = size(hier.org_ms_matrix,2) - 2;
    leaves_ms = [(1:leave_sum)',zeros(leave_sum,zero_col_num),((1:leave_sum)+leave_sum)'];
    temp_ms = hier.org_ms_matrix;
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
    [new_sp_cand,indexes] = get_sp_cand(cands,line_frame_sp_mat,f);
    sp_cand = get_org_sp_cands(new_sp_cand,hier.new_to_org);
    sp_cand(sp_cand > 0) = sp_cand(sp_cand > 0) + double(leave_sum);
    if ~isempty(f_ms)
        [cands_hf, ~] = hole_filling(double(f_lp), double(f_ms), sp_cand);
    else
        cands_hf = sp_cand;
    end
    [feats, ~] = compute_full_features(cands_hf,b_feats);
    sp_flow_info = sp_flow_info_set{f};
%     cands_hf(cands_hf > 0) = cands_hf(cands_hf > 0) - double(leave_sum);
    cands_hf = new_sp_cand;
    cand_motion_scores = get_motion_scores(cands_hf, sp_flow_info);
    cand_appearence_scores = regRF_predict(feats,rf_regressor);
    max_appearence_score = max(1,max(cand_appearence_scores));
    cand_appearence_scores = cand_appearence_scores / max_appearence_score;
    scores(indexes,f) = cand_appearence_scores * 0.7 + cand_motion_scores * 0.3;
end

scores = sort(scores,2,'descend');
avg_scores = zeros(size(cand_info,1),1);
cand_length = floor(cand_info(:,4));
for i = 1:size(scores,1)
    score_sum = sum(scores(i,1:cand_length(i)));
    avg_scores(i) = score_sum / cand_length(i);
end

function org_sp_cand = get_org_sp_cands(sp_cand,new_to_org)
org_sp_cand = zeros(size(sp_cand));
for i = 1:size(sp_cand,1)
    sps = sp_cand(i,:);
    sps = sps(sps > 0);
    org_sps = new_to_org(sps);
    org_sp_cand(i,1:length(org_sps)) = org_sps;
end

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