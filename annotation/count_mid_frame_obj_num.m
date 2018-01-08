% annotation_info = load('annotation_info.mat');
% annotation_info = annotation_info.annotation_info;
% [r,c] = size(annotation_info);
% base_path = '/home/sunx/dataset/ImageNet/Annotations';
% for i = 1:r
%     for j = 1:c
%         a = annotation_info{i,j};
%         if isempty(a)
%             continue;
%         end
%         mid_frame = floor(a.length / 2);    % mid frame id
%         mid_frame_str = num2str(mid_frame,'%06d');
%         mid_frame_file = [mid_frame_str,'.xml'];
%         xml_path = fullfile(base_path, a.package_dir, a.video_dir, mid_frame_file);
%         xml = xmlread(xml_path);
%         object_xmls = xml.getElementsByTagName('object');
%         a.mid_obj_num = object_xmls.getLength; % object num of in mid frame
%         a.obj_num = i;                      % object sum
%         annotation_info{i,j} = a;
%     end
% end
% 
% % supplement exact obj num of videos with 10+ obj
% for j = 1:c
%     a = annotation_info{r,j};
%     if isempty(a)
%         continue;
%     end
%     object_num = 0;
%     xmls = dir(fullfile(base_path, a.package_dir, a.video_dir,'*.xml'));
%     for f = 1:length(xmls)  % each xml
%         xml_file_path = fullfile(base_path, a.package_dir, a.video_dir, xmls(f).name);
%         xml = xmlread(xml_file_path);
%         object_xmls = xml.getElementsByTagName('object');
%         for o = 0:object_xmls.getLength-1   % each object
%             object = object_xmls.item(o);
%             track_id = object.getElementsByTagName('trackid').item(0);  % start from 0
%             track_id = str2double(track_id.getTextContent());
%             object_num = max(object_num, track_id + 1);
%         end
%     end
%     a.obj_num = object_num;                 % object sum
%     annotation_info{r,j} = a;
% end
% save('annotation_info.mat','annotation_info');