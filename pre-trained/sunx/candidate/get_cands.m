% cands:将sp串进行组合
% cands_info:串组合的信息：id / start_frame / end_frame / length
function [cands,cand_info] = get_cands(org_line_labels,long_line_info, new_line_labels, adjacent_sp_mats)
long_line_adjacent_mat = cal_adjacent_line_2(org_line_labels, long_line_info, adjacent_sp_mats, new_line_labels);
long_line_conbine_threshold = 0.3;  % 空间上相交的帧数/两者中较短的串的长度
half_long_line_adjacent_mat = tril(long_line_adjacent_mat);
[new_lines1,new_lines2,~] = find(half_long_line_adjacent_mat > long_line_conbine_threshold);
long_line_sum = size(long_line_info , 1);
long_line_labels = 1:long_line_sum;             % 所有长串的新串号
long_line_labels = long_line_labels';           % 转为列向量
one_line_cands = [long_line_labels zeros(long_line_sum,3)];                 % 所有单个长串作为candidate
cand_info = long_line_info(:,1:4);
cand_info(:,1) = 1:size(cand_info,1);
two_line_cands = zeros(size(new_lines1,1),4);
two_line_cand_counter = 0;
for i = 1:size(new_lines1,1)
    line1 = new_lines1(i);
    line2 = new_lines2(i);
    if ~contain_background(long_line_info, [line1;line2])
        two_line_cand_counter = two_line_cand_counter + 1;
        two_line_cands(two_line_cand_counter,1:2) = [line1 line2];
    end
end
two_line_cands = two_line_cands(1:two_line_cand_counter,:);
if ~isempty(two_line_cands)
    two_line_cand_info = get_cand_info(two_line_cands,2,long_line_info,size(cand_info,1) + 1);
    cand_info = cat(1,cand_info,two_line_cand_info);
end
three_line_cand_sum = long_line_sum * (long_line_sum - 1) * (long_line_sum - 2) / 6;
three_line_cands = zeros(three_line_cand_sum,4);                            % 三三无重复组合作为candidate 
three_line_cand_counter = 0;
for i = 1:long_line_sum - 2
    for j = i + 1 : long_line_sum - 1
        for k = j + 1 : long_line_sum
            adjacent_counter = 0;
            i_j = long_line_adjacent_mat(i,j);
            i_k = long_line_adjacent_mat(i,k);
            j_k = long_line_adjacent_mat(j,k);
            if i_j > long_line_conbine_threshold
                adjacent_counter = adjacent_counter + 1;
            end
            if i_k > long_line_conbine_threshold
                adjacent_counter = adjacent_counter + 1;
            end
            if j_k > long_line_conbine_threshold
                adjacent_counter = adjacent_counter + 1;
            end
            if adjacent_counter > 1 && ~contain_background(long_line_info, [i;j;k])% 三个长串有两组相邻即可组合
                three_line_cand_counter = three_line_cand_counter + 1;
                three_line_cands(three_line_cand_counter,1) = i;
                three_line_cands(three_line_cand_counter,2) = j;
                three_line_cands(three_line_cand_counter,3) = k;
            end
        end
    end
end
three_line_cands = three_line_cands(1:three_line_cand_counter, :);
if ~isempty(three_line_cands)
    three_line_cand_info = get_cand_info(three_line_cands,3,long_line_info,size(cand_info,1) + 1);
    cand_info = cat(1,cand_info,three_line_cand_info);
end
cands = [one_line_cands;two_line_cands;three_line_cands];
cands_statistic = sprintf('one: %d two: %d three: %d', size(one_line_cands,1), size(two_line_cands,1), size(three_line_cands,1));
disp(cands_statistic);
% cands = one_line_cands;
% === 只用来展示串的长度分布，可以注释掉
% line_length = line_info(:,4);
% line_length(line_length < 3) = [];
% hist(line_length,1:frame);
% sum(length(line_length(line_length >= 10)))
% ======================================
% cand_size:candidate 由几个串组成

function result = contain_background(long_line_info, lines)
bcs = long_line_info(lines,5);
result = false;
if ~isempty(find(bcs > 0.9, 1))
    result = true;
end


function cand_info = get_cand_info(cands, cand_size, line_info,start_id)
cand_info = zeros(size(cands)); % cand id / start_frame / end_frame / length
cand_info(:,1) = start_id:start_id + size(cands,1) - 1;   % 填入临时cand id
cand_info(:,2) = +Inf;
for i = 1:cand_size
    info = line_info(cands(:,i),:);
    start_frames = min(cand_info(:,2),info(:,2));
    end_frames = max(cand_info(:,3),info(:,3));
    cand_info(:,2) = start_frames;
    cand_info(:,3) = end_frames;
end
cand_info(:,4) = cand_info(:,3) - cand_info(:,2) + 1;