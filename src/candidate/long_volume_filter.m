% 将长度不小于min_volume_length的串过滤出来，并重新标号
function [long_volume_info, new_volume_labels] = long_volume_filter(volume,sp_boundary_connectivity_set)
long_volume_length_ratio = 0.1;
video_length = length(sp_boundary_connectivity_set);
min_volume_length = round(video_length * long_volume_length_ratio);
min_volume_length = min(min_volume_length,10);
boundary_connectivity_ths = 1;
boundary_connectivity_ths2 = 2;
volume_labels = volume(:,:,1);
max_volume_label = double(max(max(volume_labels)));
volume_info = zeros(max_volume_label,6);    % index索引串号：串号,start_frame,end_frame,length
for f=1:size(volume_labels,2)             % 遍历每一帧，收集所有串的信息
    sp = 1;
    sp_boundary_connectivity_mat = sp_boundary_connectivity_set{f};
    volume_record = zeros(max_volume_label,2);
    while(volume_labels(sp,f) > 0)        % 遍历每一个sp
        volume = volume_labels(sp,f);       % 串号
        volume_info(volume,1) = volume;       % 记录串号
        if volume_info(volume,2) == 0       % 这个串第一次出现
            volume_info(volume,2) = f;      % 标记起始帧
        end
        volume_info(volume,3) = f;  % 更新结束帧
        sp_boundary_connectivity = sp_boundary_connectivity_mat(sp);
        if sp_boundary_connectivity > boundary_connectivity_ths && volume_record(volume,1) == 0
            volume_info(volume,5) = volume_info(volume,5) + 1;
            volume_record(volume,1) = 1;
        end
        if sp_boundary_connectivity > boundary_connectivity_ths2 && volume_record(volume,2) == 0
            volume_info(volume,6) = volume_info(volume,6) + 1;
            volume_record(volume,2) = 1;
        end
        sp = sp+1;
    end
end
volume_info(:,4) = volume_info(:,3) - volume_info(:,2) + 1;           % 计算串长
% volume_info(:,5) = volume_info(:,5) ./ volume_info(:,4);              % 计算被认定为背景的次数所占串长的比例
long_volume_info = volume_info(volume_info(:,4) >= min_volume_length,:); % 消去长度小于10的串
% 串号映射串在volume_info中的index，相当于给每一个串设置了一个新的连续的id
new_volume_labels = zeros(max_volume_label,1);           
for i = 1:size(long_volume_info,1)
    new_volume_labels(long_volume_info(i,1)) = i;
end
