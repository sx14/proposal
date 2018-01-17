function line_interval_mat = get_line_interval(line_info,cand_interval_ths)
line_sum = size(line_info,1);
line_start_mat = repmat(line_info(:,2),1,line_sum);
line_end_mat = repmat(line_info(:,3),1,line_sum);
line_interval_mat = line_end_mat - line_start_mat';
line_interval_mat(line_interval_mat > 0 | line_interval_mat < (-cand_interval_ths)) = 0;
% line_interval_mat = line_interval_mat & line_interval_mat;
line_interval_mat = abs(line_interval_mat);

