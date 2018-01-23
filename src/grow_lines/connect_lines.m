function [line_info,line_frame_sp_mat,new_line_labels] = connect_lines(line_info, line_frame_sp_mat, connect_line_cand_mat, new_line_labels)
    temp = sum(connect_line_cand_mat,2);
    line_connect_max = length(temp(temp > 0));
    frame_sum = size(line_frame_sp_mat,2);
    line_connect_mat = zeros(line_connect_max, frame_sum);
    next_connect_index = 0;
    connect_done = zeros(size(connect_line_cand_mat,1),1);
    connect_counter = ones(size(connect_line_cand_mat,1),1);
    for i = 1:size(connect_line_cand_mat,1)
        [~,second,~] = find(connect_line_cand_mat(i,:) > 0);
        if ~isempty(second)  % 创建一个新的连接串， i为起始串
            if connect_done(i) == 0
                next_connect_index = next_connect_index + 1;
                line_connect_mat(next_connect_index,connect_counter(i)) = i;
                connect_counter(i) = connect_counter(i) + 1;
                connect_done(i) = 1;
            end
        end
        if ~isempty(second)
            [~,s] = max(connect_line_cand_mat(i,:));
            while s ~= 0    % 递归填入被连接的串
                if connect_done(s) == 0
                    line_connect_mat(next_connect_index,connect_counter(i)) = s;
                    connect_counter(i) = connect_counter(i) + 1;
                    connect_done(s) = 1;
                end
                [~,t,~] = find(connect_line_cand_mat(s,:) > 0);
                if ~isempty(t)  % 找到下一个被连接的串
                    s = t(1);
                else
                    s = 0;
                end
            end
        end
    end
    line_connect_mat = line_connect_mat(1:next_connect_index,:);
    new_line_info = zeros(next_connect_index,6);
    new_line_frame_sp_mat = zeros(next_connect_index,frame_sum,2);
    org_line_sum = size(line_info,1);
    for i = 1:size(line_connect_mat,1)
        connect_line_label = org_line_sum + i;
        line_connect = line_connect_mat(i,:);
        lines = line_connect(line_connect > 0);
        start_frame = frame_sum;
        end_frame = 0;
        boundary_connectivity = 0;
        boundary_connectivity1 = 0;
        for j = 1:length(lines)
            line = lines(j);
            old_line_label = line_info(line,1);
            new_line_labels(old_line_label) = connect_line_label;
            curr_s = line_info(line,2);
            curr_e = line_info(line,3);
            boundary_connectivity = boundary_connectivity + line_info(line,5);
            boundary_connectivity1 = boundary_connectivity1 + line_info(line,6);
            start_frame = min(start_frame,curr_s);
            end_frame = max(end_frame,curr_e);
            new_line_frame_sp_mat(i,curr_s:curr_e,:) = line_frame_sp_mat(line,curr_s:curr_e,:);
        end
        new_line_info(i,1) = connect_line_label;
        new_line_info(i,2) = start_frame;
        new_line_info(i,3) = end_frame;
        new_line_info(i,4) = end_frame - start_frame + 1;
        new_line_info(i,5) = boundary_connectivity;
        new_line_info(i,6) = boundary_connectivity1;
    end
    line_info = cat(1,line_info,new_line_info);
    line_info(:,5) = line_info(:,5) ./ line_info(:,4);
    line_info(:,6) = line_info(:,6) ./ line_info(:,4);
    line_frame_sp_mat = cat(1,line_frame_sp_mat,new_line_frame_sp_mat);
end

