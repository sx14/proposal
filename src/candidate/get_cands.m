% cands:将sp串进行组合
% cands_info:串组合的信息：id / start_frame / end_frame / length
function [cands,cand_info] = get_cands(long_volume_info, long_volume_adjacent_mat)
half_long_volume_adjacent_mat = tril(long_volume_adjacent_mat);
[new_volumes1,new_volumes2,~] = find(half_long_volume_adjacent_mat > 0);
% === cal boundary connectivity (ratio)===
long_volume_info(:,5) = long_volume_info(:,5) ./ long_volume_info(:,4);
long_volume_info(:,6) = long_volume_info(:,6) ./ long_volume_info(:,4);
% ========================================
long_volume_sum = size(long_volume_info , 1);
long_volume_labels = 1:long_volume_sum;             % 所有长串的新串号
long_volume_labels = long_volume_labels';           % 转为列向量
one_volume_cands = [long_volume_labels zeros(long_volume_sum,3)];                 % 所有单个长串作为candidate
cand_info = get_cand_info(one_volume_cands,1,long_volume_info,1);
two_volume_cand_max = long_volume_sum * (long_volume_sum - 1) / 2*1;
two_volume_cand_max = min((10000-size(cand_info,1)), two_volume_cand_max);
two_volume_cands = zeros(size(two_volume_cand_max,1),4);
two_volume_cand_counter = 0;
for i = 1:size(new_volumes1,1)
    volume1 = new_volumes1(i);
    volume2 = new_volumes2(i);
    if ~contain_background(long_volume_info, [volume1;volume2])
        two_volume_cand_counter = two_volume_cand_counter + 1;
        if two_volume_cand_counter <= two_volume_cand_max
            two_volume_cands(two_volume_cand_counter,1:2) = [volume1 volume2];
        else
            two_volume_cand_counter = two_volume_cand_max;
            break;
        end
    end
end
two_volume_cands = two_volume_cands(1:two_volume_cand_counter,:);
if ~isempty(two_volume_cands)
    two_volume_cand_info = get_cand_info(two_volume_cands,2,long_volume_info,size(cand_info,1) + 1);
    cand_info = cat(1,cand_info,two_volume_cand_info);
end
three_volume_cand_max = long_volume_sum * (long_volume_sum - 1) * (long_volume_sum - 2) / 3*2*1;
three_volume_cand_max = min((10000-size(cand_info,1)), three_volume_cand_max);
three_volume_cands = zeros(three_volume_cand_max,4);                            % 三三无重复组合作为candidate
three_volume_cand_counter = 0;
for i = 1:long_volume_sum - 2
    for j = i + 1 : long_volume_sum - 1
        for k = j + 1 : long_volume_sum
            adjacent_counter = 0;
            i_j = long_volume_adjacent_mat(i,j);
            i_k = long_volume_adjacent_mat(i,k);
            j_k = long_volume_adjacent_mat(j,k);
            if i_j > 0
                adjacent_counter = adjacent_counter + 1;
            end
            if i_k > 0
                adjacent_counter = adjacent_counter + 1;
            end
            if j_k > 0
                adjacent_counter = adjacent_counter + 1;
            end
            if adjacent_counter > 1 && ~contain_background(long_volume_info, [i;j;k])% 三个长串有两组相邻即可组合
                three_volume_cand_counter = three_volume_cand_counter + 1;
                if three_volume_cand_counter <= three_volume_cand_max
                    three_volume_cands(three_volume_cand_counter,1) = i;
                    three_volume_cands(three_volume_cand_counter,2) = j;
                    three_volume_cands(three_volume_cand_counter,3) = k;
                else
                    three_volume_cand_counter = three_volume_cand_max;
                    break;
                end
            end
        end
    end
end
three_volume_cands = three_volume_cands(1:three_volume_cand_counter, :);
if ~isempty(three_volume_cands)
    three_volume_cand_info = get_cand_info(three_volume_cands,3,long_volume_info,size(cand_info,1) + 1);
    cand_info = cat(1,cand_info,three_volume_cand_info);
end

four_volume_cand_max = long_volume_sum * (long_volume_sum - 1) * (long_volume_sum - 2) * (long_volume_sum - 3) / 4*3*2*1;
four_volume_cand_max = min((10000-size(cand_info,1)), four_volume_cand_max);
four_volume_cands = zeros(four_volume_cand_max,4);    % 四四无重复组合作为candidate
four_volume_cand_counter = 0;
for i = 1:long_volume_sum - 3
    for j = i + 1 : long_volume_sum - 2
        for k = j + 1 : long_volume_sum - 1
            for l = k + 1 : long_volume_sum
                adjacent_counter = 0;
                i_j = long_volume_adjacent_mat(i,j);
                i_k = long_volume_adjacent_mat(i,k);
                i_l = long_volume_adjacent_mat(i,l);
                j_k = long_volume_adjacent_mat(j,k);
                j_l = long_volume_adjacent_mat(j,l);
                k_l = long_volume_adjacent_mat(k,l);
                if i_j > 0
                    adjacent_counter = adjacent_counter + 1;
                end
                if i_k > 0
                    adjacent_counter = adjacent_counter + 1;
                end
                if i_l > 0
                    adjacent_counter = adjacent_counter + 1;
                end
                if j_k > 0
                    adjacent_counter = adjacent_counter + 1;
                end
                if j_l > 0
                    adjacent_counter = adjacent_counter + 1;
                end
                if k_l > 0
                    adjacent_counter = adjacent_counter + 1;
                end
                if adjacent_counter > 3 && ~contain_background(long_volume_info, [i;j;k])% 三个长串有两组相邻即可组合
                    four_volume_cand_counter = four_volume_cand_counter + 1;
                    if four_volume_cand_counter <= four_volume_cand_max
                        four_volume_cands(four_volume_cand_counter,1) = i;
                        four_volume_cands(four_volume_cand_counter,2) = j;
                        four_volume_cands(four_volume_cand_counter,3) = k;
                        four_volume_cands(four_volume_cand_counter,4) = l;
                    else
                        four_volume_cand_counter = four_volume_cand_max;
                        break;
                    end
                end
            end
        end
    end
end
four_volume_cands = four_volume_cands(1:four_volume_cand_counter, :);
if ~isempty(four_volume_cands)
    four_volume_cand_info = get_cand_info(four_volume_cands,4,long_volume_info,size(cand_info,1) + 1);
    cand_info = cat(1,cand_info,four_volume_cand_info);
end

cands = [one_volume_cands;two_volume_cands;three_volume_cands;four_volume_cands];
cands_statistic = sprintf('one: %d two: %d three: %d four: %d', size(one_volume_cands,1), size(two_volume_cands,1), size(three_volume_cands,1),size(four_volume_cands,1));
disp(cands_statistic);

function result = contain_background(long_volume_info, volumes)
bcs = long_volume_info(volumes,5);
result = false;
if ~isempty(find(bcs > 0.9, 1))
    result = true;
end


function cand_info = get_cand_info(cands, cand_size, volume_info,start_id)
cand_info = zeros(size(cands,1),6); % cand id / start_frame / end_frame / length
cand_info(:,1) = start_id:(start_id + size(cands,1) - 1);   % 填入临时cand id
cand_info(:,2) = +Inf;
for i = 1:cand_size
    info = volume_info(cands(:,i),:);
    start_frames = min(cand_info(:,2),info(:,2));
    end_frames = max(cand_info(:,3),info(:,3));
    cand_info(:,2) = start_frames;
    cand_info(:,3) = end_frames;
    if cand_size == 1
        cand_info(:,6) = info(:,6);
    end
end
cand_info(:,4) = cand_info(:,3) - cand_info(:,2) + 1;
cand_info(:,5) = cand_size;