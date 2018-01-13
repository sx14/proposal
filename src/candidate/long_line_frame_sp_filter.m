function long_line_frame_sp_mat = long_line_frame_sp_filter(line_frame_sp_mat,all_line_info,min_length)
    long_line_frame_sp_mat = line_frame_sp_mat(all_line_info(:,4) >= min_length,:);
end

