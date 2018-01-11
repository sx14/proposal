% 将长度不小于min_line_length的串过滤出来，并重新标号
function [long_line_info,all_line_info,new_line_labels] = long_line_filter(net,sp_boundary_connectivity_set)
min_line_length = 10;
boundary_connectivity_ths = 1;
line_labels = net(:,:,1);
max_line_label = double(max(max(line_labels)));
all_line_info = zeros(max_line_label,5);    % index索引串号：串号,start_frame,end_frame,length
for f=1:size(line_labels,2)             % 遍历每一帧，收集所有串的信息
    sp = 1;
    sp_boundary_connectivity_mat = sp_boundary_connectivity_set{f};
    while(line_labels(sp,f) > 0)            % 遍历每一个sp
        line = line_labels(sp,f);           % 串号
        all_line_info(line,1) = line;       % 记录串号
        if all_line_info(line,2) == 0       % 这个串第一次出现
            all_line_info(line,2) = f;      % 标记起始帧
        end
        all_line_info(line,3) = f;  % 更新结束帧
        sp_boundary_connectivity = sp_boundary_connectivity_mat(sp);
        if sp_boundary_connectivity > boundary_connectivity_ths
            all_line_info(line,5) = all_line_info(line,5) + 1;
        end
        sp = sp+1;
    end
end
all_line_info(:,4) = all_line_info(:,3) - all_line_info(:,2) + 1;   % 计算串长
% all_line_info(:,5) = all_line_info(:,5) ./ all_line_info(:,4);      % 计算被认定为背景的次数所占串长的比例
long_line_info = all_line_info(all_line_info(:,4) >= min_line_length,:);
% 串号映射串在all_line_info中的index，相当于给每一个串设置了一个新的连续的id
new_line_labels = zeros(max_line_label,1);           
for i = 1:size(long_line_info,1)
    new_line_labels(long_line_info(i,1)) = i;
end
