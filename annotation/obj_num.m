video_list = load('selected_video_list.mat');
video_list = video_list.selected_video_list;
video_list = video_list(:,1:25);
an_list = load('annotation_info.mat');
an_list = an_list.annotation_info;
video_sum = 0;
obj_sum = 0;
for i = 1:10
    for j = 1:4000
        a = an_list{i,j};
        if ~isempty(a)
%             if ismember(a.video_dir,video_list,'rows')
                video_sum = video_sum + 1;
                obj_sum = obj_sum + a.obj_num;
%             end
        end
    end
end

avg = obj_sum / video_sum;