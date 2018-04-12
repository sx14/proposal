function [volume_info,volume_frame_sp_mat,new_volume_labels] = connect_volumes(volume_info, volume_frame_sp_mat, connect_volume_cand_mat, new_volume_labels)
    temp = sum(connect_volume_cand_mat,2);
    volume_connect_max = length(temp(temp > 0));
    frame_sum = size(volume_frame_sp_mat,2);
    volume_connect_mat = zeros(volume_connect_max, frame_sum);
    next_connect_index = 0;
    connect_done = zeros(size(connect_volume_cand_mat,1),1);
    connect_counter = ones(size(connect_volume_cand_mat,1),1);
    for i = 1:size(connect_volume_cand_mat,1)
        [~,second,~] = find(connect_volume_cand_mat(i,:) > 0);
        if ~isempty(second)  % 创建一个新的连接串， i为起始串
            if connect_done(i) == 0
                next_connect_index = next_connect_index + 1;
                volume_connect_mat(next_connect_index,connect_counter(i)) = i;
                connect_counter(i) = connect_counter(i) + 1;
                connect_done(i) = 1;
            end
        end
        if ~isempty(second)
            [~,s] = max(connect_volume_cand_mat(i,:));
            while s ~= 0    % 递归填入被连接的串
                if connect_done(s) == 0
                    volume_connect_mat(next_connect_index,connect_counter(i)) = s;
                    connect_counter(i) = connect_counter(i) + 1;
                    connect_done(s) = 1;
                end
                [~,t,~] = find(connect_volume_cand_mat(s,:) > 0);
                if ~isempty(t)  % 找到下一个被连接的串
                    s = t(1);
                else
                    s = 0;
                end
            end
        end
    end
    volume_connect_mat = volume_connect_mat(1:next_connect_index,:);
    new_volume_info = zeros(next_connect_index,6);
    new_volume_frame_sp_mat = zeros(next_connect_index,frame_sum,2);
    org_volume_sum = volume_info(end,1);
    for i = 1:size(volume_connect_mat,1)
        connect_volume_label = org_volume_sum + i;
        volume_connect = volume_connect_mat(i,:);
        volumes = volume_connect(volume_connect > 0);
        start_frame = frame_sum;
        end_frame = 0;
        boundary_connectivity = 0;
        boundary_connectivity1 = 0;
        for j = 1:length(volumes)
            volume = volumes(j);
            old_volume_label = volume_info(volume,1);
            new_volume_labels(old_volume_label) = connect_volume_label;
            curr_s = volume_info(volume,2);
            curr_e = volume_info(volume,3);
            boundary_connectivity = boundary_connectivity + volume_info(volume,5);
            boundary_connectivity1 = boundary_connectivity1 + volume_info(volume,6);
            start_frame = min(start_frame,curr_s);
            end_frame = max(end_frame,curr_e);
            new_volume_frame_sp_mat(i,curr_s:curr_e,:) = volume_frame_sp_mat(volume,curr_s:curr_e,:);
        end
        new_volume_info(i,1) = connect_volume_label;
        new_volume_info(i,2) = start_frame;
        new_volume_info(i,3) = end_frame;
        new_volume_info(i,4) = end_frame - start_frame + 1;
        new_volume_info(i,5) = boundary_connectivity;
        new_volume_info(i,6) = boundary_connectivity1;
    end
    volume_info = cat(1,volume_info,new_volume_info);
    volume_info(:,5) = volume_info(:,5) ./ volume_info(:,4);
    volume_info(:,6) = volume_info(:,6) ./ volume_info(:,4);
    volume_frame_sp_mat = cat(1,volume_frame_sp_mat,new_volume_frame_sp_mat);
end

