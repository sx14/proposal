% 获取单个视频的处理结果
function [recall, smT_IoU] = get_result_for_one_video(base_path, package_dir, video_dir,annotation_path,show,output_path)
video_path = fullfile(base_path, package_dir, video_dir);
% if ~exist(fullfile(video_path,'result'),'file')
    [net,hiers,org_imgs,adjacent_sp_mats] = connect_images(video_path, 2000);
    [long_line_info, new_line_labels] = long_line_filter(net, round(length(org_imgs) * 0.2));
    [cands,cand_info] = cal_bundle_cands(net(:,:,1),long_line_info, new_line_labels, adjacent_sp_mats);
    long_line_frame_sp_mat = get_line_frame_sp(net, long_line_info, new_line_labels);
%     proposals = get_proposals(hiers,cands,line_frame_sp_mat,cand_info,package_dir,video_dir);
    [ground_truth_info, annotations,org_height, org_width] = annotation_xml_2_struct(annotation_path);
    [recall,smT_IoU,hit] = cal_recall(ground_truth_info, annotations, hiers, cands, long_line_info, long_line_frame_sp_mat, org_width,org_height);
    output_info = sprintf('Recall: %.2f%% smT_IoU: %.2f%% object_sum: %d candidate_sum: %d', recall * 100, smT_IoU * 100, size(hit,1),size(cands,1));
    disp(output_info);
    for i = 1:size(hit,1)
        h = output_info(1,:);
        h(:) = ' ';
        h_content = sprintf('%d : %.2f%%', i, hit(i,2)*100);
        h(1:length(h_content)) = h_content;
        disp(h);
        output_info = [output_info;h];
    end
    output_path = fullfile(output_path, 'result');
    output(output_path, [video_dir '.txt'], output_info, 'txt');
    
% end
if show
    input('show ?');
    show_hit(hiers,org_imgs,hit,cands,long_line_frame_sp_mat,annotations,org_height, org_width);
end
