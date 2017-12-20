% 将sp串进行组合
function cands = cal_bundle_cands(org_line_labels,long_line_info, new_line_labels, adjacent_sp_mats)
long_line_adjacent_mat = cal_adjacent_line_2(org_line_labels, long_line_info, adjacent_sp_mats, new_line_labels);
long_line_adjacent_mat = tril(long_line_adjacent_mat);
[new_lines1,new_lines_2,~] = find(long_line_adjacent_mat > 0);
long_line_labels = 1:size(long_line_info,1);    % 所有长串的新串号
long_line_labels = long_line_labels';           % 转为列向量
one_line_cands = [long_line_labels zeros(size(long_line_labels))];
two_line_cands = [new_lines1 new_lines_2];    % 两两全组合
cands = [one_line_cands;two_line_cands];
% cands = one_line_cands;
% === 只用来展示串的长度分布，可以注释掉
% line_length = line_info(:,4);
% line_length(line_length < 3) = [];
% hist(line_length,1:frame);
% sum(length(line_length(line_length >= 10)))
% ======================================