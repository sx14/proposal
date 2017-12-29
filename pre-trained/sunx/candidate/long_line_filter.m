% 将长度不小于min_line_length的串过滤出来，并重新标号
function [long_line_info, new_line_labels] = long_line_filter(net, min_line_length,sp_boundary_connectivity_set)
boundary_connectivity_ths = 2;
line_labels = net(:,:,1);
max_line_label = double(max(max(line_labels)));
line_info = zeros(max_line_label,5);    % index索引串号：串号,start_frame,end_frame,length
for f=1:size(line_labels,2)             % 遍历每一帧，收集所有串的信息
    sp = 1;
    sp_boundary_connectivity_mat = sp_boundary_connectivity_set{f};
    while(line_labels(sp,f) > 0)        % 遍历每一个sp
        line = line_labels(sp,f);       % 串号
        line_info(line,1) = line;   % 记录串号
        if line_info(line,2) == 0   % 这个串第一次出现
            line_info(line,2) = f;  % 标记起始帧
        end
        line_info(line,3) = f;  % 更新结束帧
        sp_boundary_connectivity = sp_boundary_connectivity_mat(sp);
        if sp_boundary_connectivity > boundary_connectivity_ths
            line_info(line,5) = line_info(line,5) + 1;
        end
        sp = sp+1;
    end
end
line_info(:,4) = line_info(:,3) - line_info(:,2) + 1;   % 计算串长
line_info(:,5) = line_info(:,5) ./ line_info(:,4);      % 计算被认定为背景的次数所占串长的比例
short_lines = find(line_info(:,4) < min_line_length);   % 所有不超过10帧的串
line_info(short_lines,:) = [];                          % 消去长度小于10的串
% 串号映射串在line_info中的index，相当于给每一个串设置了一个新的连续的id
new_line_labels = zeros(max_line_label,1);           
for i = 1:size(line_info,1)
    new_line_labels(line_info(i,1)) = i;
end
long_line_info = line_info;
