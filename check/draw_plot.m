clear;clc;close all;
ours_output_path = '/home/sunx/output/ours/result';
compare_output_path = '/home/sunx/output/VMCG/result';
video_list_file = load('video_list.mat');
video_list = video_list_file.video_list;
our_results = dir(fullfile(ours_output_path,'*.mat'));
other_results = dir(fullfile(compare_output_path,'*.mat'));
counter = 0;
recall = [];
mT_IoU = [];
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
    if ~isempty(our_result) && ~isempty(other_result)
        our_result = our_result.result;
        other_result = other_result.result;
        counter = counter + 1;
        if counter == 1
            recall = zeros(size(our_result.hit,2)+1,2); % 添一个0
            mT_IoU = zeros(size(our_result.hit,2)+1,2); % 添一个0
        end
        temp = our_result.hit(:,:,2);
        s_mT_IoU = sum(temp,1) / size(our_result.hit,1);
        mT_IoU(:,1) = mT_IoU(:,1) + [0,s_mT_IoU]';
        temp(temp <= 0.5) = 0;
        temp = temp & temp;
        s_recall = sum(temp,1) / size(our_result.hit,1);
        recall(:,1) = recall(:,1) + [0,s_recall]';
        temp = other_result.hit(:,:,2);
        s_mT_IoU = sum(temp,1) / size(other_result.hit,1);
        mT_IoU(:,2) = mT_IoU(:,2) + [0,s_mT_IoU]';
        temp(temp <= 0.5) = 0;
        temp = temp & temp;
        s_recall = sum(temp,1) / size(other_result.hit,1);
        recall(:,2) = recall(:,2) + [0,s_recall]';
    end
end
recall = recall / counter;
mT_IoU = mT_IoU / counter;
x = 0:20:1000;
figure,plot(x,recall(:,1),'r-',x,recall(:,2),'g:');
figure,plot(x,mT_IoU(:,1),'r-',x,mT_IoU(:,2),'g:');

