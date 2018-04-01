function volume_interval_mat = get_volume_interval(volume_info,cand_interval_ths)
volume_sum = size(volume_info,1);
volume_start_mat = repmat(volume_info(:,2),1,volume_sum);
volume_end_mat = repmat(volume_info(:,3),1,volume_sum);
volume_interval_mat = volume_end_mat - volume_start_mat';
volume_interval_mat(volume_interval_mat > 0 | volume_interval_mat < (-cand_interval_ths)) = 0;
% volume_interval_mat = volume_interval_mat & volume_interval_mat;
volume_interval_mat = abs(volume_interval_mat);

