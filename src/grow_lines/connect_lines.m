function [net,all_line_info] = connect_lines(net,all_line_info,long_line_info,line_frame_sp_mat,connect_line_cand_mat)
    temp = sum(connect_line_cand_mat,2);
    line_connect_max = length(temp(temp > 0));
    frame_sum = size(line_frame_sp_mat,2);
    line_connect_mat = zeros(line_connect_max, frame_sum);
    next_connect_index = 0;
    connect_done = zeros(size(connect_line_cand_mat,1),1);
    connect_counter = ones(size(connect_line_cand_mat,1),1);
    for i = 1:size(connect_line_cand_mat,1)
        [~,second,~] = find(connect_line_cand_mat(i,:) > 0);
        if ~isempty(second)
            if connect_done(i) == 0 % 创建一个新的连接串， i为起始串
                next_connect_index = next_connect_index + 1;
                line_connect_mat(next_connect_index,connect_counter(i)) = i;
                connect_counter(i) = connect_counter(i) + 1;
                connect_done(i) = 1;
            end
            [~,s] = max(connect_line_cand_mat(i,:));
            while s ~= 0    % 递归填入被连接的串
                if connect_done(s) == 0
                    line_connect_mat(next_connect_index,connect_counter(i)) = s;
                    connect_counter(i) = connect_counter(i) + 1;
                    connect_done(s) = 1;
                end
                [~,t,~] = find(connect_line_cand_mat(s,:) > 0);
                if ~isempty(t)  % 找到下一个被连接的串
                    [~,s] = max(connect_line_cand_mat(i,:));
                else
                    s = 0;
                end
            end
        end
    end
    line_connect_mat = line_connect_mat(1:next_connect_index,:);
    new_long_line_info = zeros(next_connect_index,5);
    org_line_sum = size(long_line_info,1);
    for i = 1:size(line_connect_mat,1)
        connect_line_label = org_line_sum + i;
        line_connect = line_connect_mat(i,:);
        lines = line_connect(line_connect > 0);
        start_frame = frame_sum;
        end_frame = 0;
        boundary_connectivity = 0;
        for j = 1:length(lines)
            line = lines(j);
            old_line_label = long_line_info(line,1);
            all_line_info(old_line_label,1:end) = 0;    % 消除旧串记录
            curr_s = long_line_info(line,2);
            curr_e = long_line_info(line,3);
            for f = curr_s:curr_e
                frame_line = net(:,f,1);
                frame_line(frame_line == line) = connect_line_label;
                net(:,f,1) = frame_line;
            end
            boundary_connectivity = max(boundary_connectivity,long_line_info(line,5));
            start_frame = min(start_frame,curr_s);
            end_frame = max(end_frame,curr_e);
        end
        new_long_line_info(i,1) = connect_line_label;
        new_long_line_info(i,2) = start_frame;
        new_long_line_info(i,3) = end_frame;
        new_long_line_info(i,4) = end_frame - start_frame;
        new_long_line_info(i,5) = boundary_connectivity;
    end
    all_line_info = cat(1,all_line_info,new_long_line_info);
end

