clear;clc;close all;
ours_output_path = '/home/sunx/output/ours_version1/result';
compare_output_path = '/home/sunx/output/SXD/result';
video_list_file = load('video_list.mat');
video_list = video_list_file.video_list;
our_results = dir(fullfile(ours_output_path,'*.mat'));
other_results = dir(fullfile(compare_output_path,'*.mat'));
compare = zeros(length(video_list),5);
for i = 1:length(video_list)
    video_info = video_list{i};
    video_name = video_info.video_dir;
    video_id = video_name(length(video_name) - 7 : length(video_name));
    try
        our_result = load(fullfile(ours_output_path,[video_name,'.mat']));
    catch
        our_result = [];
    end
    try
        other_result = load(fullfile(compare_output_path,[video_name,'.mat']));
    catch
        other_result = [];
    end
    video_id_num = str2double(video_id);
    obj_num = -1;
    our_recall = -1;
    compare_recall = -1;
    win = -2;
    if ~isempty(our_result)
        our_recall = our_result.result.recall;
        obj_num = size(our_result.result.hit,1);
    end
    if ~isempty(other_result)
        compare_recall = other_result.result.recall;
        obj_num = size(other_result.result.hit,1);
    end
    if our_recall ~= -1 && compare_recall ~= -1
        if our_recall > compare_recall
            win = 1;
        elseif our_recall == compare_recall
            win = 0;
        elseif our_recall < compare_recall
            win = -1;
        end
    end
    compare(i,1) = video_id_num;
    compare(i,2) = obj_num;
    compare(i,3) = our_recall;
    compare(i,4) = compare_recall;
    compare(i,5) = win;
end
[i,j,~] = find(compare(:,5) == -2);
compare(i,:) = [];
video_sum = size(compare,1);
win_ratio = length(find(compare(:,5) == 1)) / video_sum;
lose_ratio = length(find(compare(:,5) == -1)) / video_sum;
tie_ratio = length(find(compare(:,5) == 0)) / video_sum;
fprintf('win:%.2f lose:%.2f tie:%.2f\n',win_ratio,lose_ratio,tie_ratio);
save(fullfile(root,'check','compare_result','compare.mat'),'compare');
win_part = compare(compare(:,5) == 1,:);
lose_part = compare(compare(:,5) == -1,:);
tie_part = compare(compare(:,5) == 0,:);
save(fullfile(root,'check','compare_result','win.mat'),'win_part');
save(fullfile(root,'check','compare_result','lose.mat'),'lose_part');
save(fullfile(root,'check','compare_result','tie.mat'),'tie_part');