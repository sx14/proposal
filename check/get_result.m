% 获取单个视频的处理结果
function [result,annotations] = get_result(video_dir,annotation_path,output_path, proposals, re_cal)
result_dir = 'result';
if ~exist(fullfile(output_path, result_dir),'dir')
    mkdir(fullfile(output_path), result_dir);   % make result dir
end
result_path = fullfile(output_path, result_dir);
result_file_name = [video_dir '.mat'];
[ground_truth_info, annotations] = annotation_xml_2_struct(annotation_path);
if ~exist(fullfile(result_path, result_file_name),'file') || re_cal == true  % not done
    [recall,smT_IoU,hit] = cal_recall(ground_truth_info, annotations, proposals);
    output_info = sprintf('Recall: %.2f%% smT_IoU: %.2f%% object_sum: %d candidate_sum: %d', recall * 100, smT_IoU * 100, size(hit,1),size(proposals,1));
    disp(output_info);
    for i = 1:size(hit,1)
        h = output_info(1,:);
        h(:) = ' ';
        proposal_id = hit(i,size(hit,2),1);
        h_content = sprintf('%d-%d : %.2f%%', i, proposal_id, hit(i,size(hit,2),2)*100);
        h(1:length(h_content)) = h_content;
        disp(h);
        output_info = [output_info;h];
        if proposal_id > 0
            copy_proposal_masks(output_path,video_dir,hit(i,size(hit,2),1));
        end
    end
    result.recall = recall;
    result.smT_IoU = smT_IoU;
    result.hit = hit;
    % result dir: video_name.txt is readable; video_name.mat contains recall, smT-IoU, hit (object named result)
    save(fullfile(result_path, [video_dir,'.mat']),'result');
    output(result_path, [video_dir '.txt'], output_info, 'txt');
else    % done read result
    result_file = load(fullfile(result_path, [video_dir,'.mat']));
    result = result_file.result;
end


function copy_proposal_masks(output_path,video_dir,proposal_id)
p_num=num2str(proposal_id,'%04d');
hit_path = fullfile(output_path,'hit');
mask_path = fullfile(output_path,'mask');
hit_video_path = fullfile(hit_path,video_dir);
hit_proposal_path = fullfile(hit_video_path,p_num);
org_proposal_path = fullfile(mask_path,video_dir,p_num);
if ~exist(hit_video_path,'dir')
    mkdir(hit_path,video_dir);
end
copyfile(org_proposal_path,hit_proposal_path);


