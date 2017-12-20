% 获取单个视频的处理结果
function get_result_for_one_video(video_path,annotation_path, resize_dir_name, flow_dir_name, flow2_dir_name, hier_dir_name, img_suffix,show)
% if ~exist(fullfile(video_path,'result'),'file')
    [net,hiers,org_imgs,adjacent_sp_mats] = connect_images(video_path, resize_dir_name, flow_dir_name, flow2_dir_name, hier_dir_name, img_suffix, 40000);
    [long_line_info, new_line_labels] = long_line_filter(net, round(length(org_imgs) * 0.10));
    cands = cal_bundle_cands(net(:,:,1),long_line_info, new_line_labels, adjacent_sp_mats);
    long_line_frame_sp_mat = get_line_frame_sp(net, long_line_info, new_line_labels);
    [ground_truth_info, annotations,org_height, org_width] = annotation_xml_2_struct(annotation_path);
    [recall,smT_IoU,hit] = cal_recall(ground_truth_info, annotations, hiers, cands, long_line_info, long_line_frame_sp_mat, org_width,org_height);
    output_info = sprintf('Recall: %.2f%% smT_IoU: %.2f%% object_sum: %d candidate_sum: %d', recall * 100, smT_IoU * 100, size(hit,1),size(cands,1));
    output(video_path, 'result', output_info, 'txt');
    disp(output_info);
% end
if show
    show_hit(hiers,org_imgs,hit,cands,long_line_frame_sp_mat,annotations,org_height, org_width);
end
