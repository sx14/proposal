function cal_bundle_cands(net)
line_label = net.lines(:,:,1);
max_line_label = double(max(max(line_label)));
line_info = zeros(max_line_label,4);    % index索引串号：串号,start_frame,end_frame,length
frame = 0;
for f=1:size(line_label,2)      % 遍历每一帧，收集所有串的信息
    frame = frame + 1;
    if line_label(1,f,1) == 0   % 到头了
        break;
    end
    sp = 1;
    while(line_label(sp,f) > 0)     % 遍历每一个sp
        line = line_label(sp,f);
        line_info(line,1) = line;
        if line_info(line,2) == 0   % 这个串第一次出现
            line_info(line,2) = f;  % 标记起始帧
            line_info(line,3) = f;  % 更新结束帧
        else
            line_info(line,3) = f;  % 更新结束帧
        end
        sp = sp+1;
    end
end
line_info(:,4) = line_info(:,3) - line_info(:,2) + 1;   % 计算串长
short_lines = find(line_info(:,4) < 10);                % 所有不超过10帧的串
line_info(short_lines,:) = [];
line_label_map = zeros(max(line_info(:,1)));            % 串号映射串在line_info中的index
for i = 1:size(line_info,1)
    line_label_map(line_info(i,1)) = i;
end
% === 只用来展示串的长度分布，可以注释掉
line_length = line_info(:,4);
line_length(line_length < 3) = [];
hist(line_length,1:frame);
sum(length(line_length(line_length > 10)))
% ======================================
adjacent_line_mat = net.adjacent_lines(1:max_line_label,1:max_line_label);  % 截取有效部分
adjacent_line_mat(short_lines,:) = 0;
adjacent_line_mat(:,short_lines) = 0;
% adjacent_line_mat现在表示的是串的空间相邻关系
% 下面计算串的时间相邻关系
% 只有在时间和空间都相邻的情况下，两个串才有可能组合
for i = size(adjacent_line_mat,1)
    for j = 1:i - 1;
        if adjacent_line_mat > 0
            start1 = line_info(i,2);
            end1 = line_info(i,3);
            start2 = line_info(j,2);
            end2 = line_info(j,3);
            i_length = min([end1,end2]) - max([start1,start2]); % 两个串相交的长度
            if i_length <= 0    % 时间上不相交
                adjacent_line_mat(i,j) = 0;
            end
        end
    end
end
adjacent_line_mat = tril(adjacent_line_mat);    % 取两两全组合
[i,j,v] = find(adjacent_line_mat > 0);  % 取两两全组合
a = 1;