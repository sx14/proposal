function avg_scores = get_cand_scores(hiers, cands, line_frame_sp_mat, cand_info, long_line_length_ratio)
rf_regressor = loadvar(fullfile(mcg_root, 'datasets', 'models', 'scg_rand_forest_train2012.mat'),'rf');
scores = zeros(size(cands,1),length(hiers));
for f = 1:length(hiers)
    hier = hiers{f};
    f_lp = hier.leaves_part;
    leave_sum = max(max(f_lp));
    leaves_ms = [(1:leave_sum)',zeros(leave_sum,1),((1:leave_sum)+leave_sum)'];
    f_ms = cat(1,leaves_ms,(hier.ms_matrix+leave_sum));
    ucm = hier.ucm;
    b_feats = compute_base_features(f_lp, f_ms, ucm);
    b_feats.start_ths = [zeros(leave_sum,1);hier.start_ths]';
    b_feats.end_ths   = [zeros(leave_sum,1);hier.end_ths]';
    b_feats.im_size   = size(f_lp);
    [sp_cand,indexes] = get_sp_cand(cands,line_frame_sp_mat,f);
    sp_cand(sp_cand > 0) = sp_cand(sp_cand > 0) + leave_sum;
    if ~isempty(f_ms)
        [cands_hf, cands_comp] = hole_filling(double(f_lp), double(f_ms), sp_cand); %#ok<NASGU>
    else
        cands_hf = sp_cand;
        cands_comp = sp_cand; %#ok<NASGU>
    end
    % Select which proposals to keep (Uncomment just one line)
    [feats, bboxes] = compute_full_features(cands_hf,b_feats);
    frame_cand_scores = regRF_predict(feats,rf_regressor);
    scores(indexes,f) = frame_cand_scores;
end

scores = sort(scores,2,'descend');
avg_scores = zeros(size(cand_info,1),1);
long_line_length_ths = floor(length(hiers) * long_line_length_ratio * 3);
long_line_ths_array = zeros(size(avg_scores));
long_line_ths_array(:) = long_line_length_ths;
[top_k,~] = min([cand_info(:,4) long_line_ths_array],[],2);
% top_k = floor(cand_info(:,4) * 0.9);
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