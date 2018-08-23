function draw_plot(output_path_set,line_style_set,legend_set)
recall_values = [];
mt_iou_values = [];
for r = 1:size(output_path_set,1)
    video_list = dir(fullfile(output_path_set{r},'*.mat'));
    counter = 0;
    recall = [];
    mT_IoU = [];
    for i = 1:size(video_list,1)
        video_name = video_list(i);
        video_name = video_name.name;
        result = load(fullfile(output_path_set{r},video_name));
        result = result.result;
        counter = counter + 1;
        if counter == 1
            recall = zeros(size(result.hit,2)+1,1); % 添一个0
            mT_IoU = zeros(size(result.hit,2)+1,1); % 添一个0
        end
        temp = result.hit(:,:,2);
        s_mT_IoU = sum(temp,1) / size(result.hit,1);
        mT_IoU(:) = mT_IoU(:) + [0,s_mT_IoU]';
        temp(temp <= 0.5) = 0;
        temp = temp & temp;
        s_recall = sum(temp,1) / size(result.hit,1);
        recall(:) = recall(:) + [0,s_recall]';
    end
    recall = recall / counter;
    mT_IoU = mT_IoU / counter;
    
    recall1 = zeros(size(recall));
    mT_IoU1 = zeros(size(mT_IoU));
    recall1(1:2:end) = recall(1:26);
    mT_IoU1(1:2:end) = mT_IoU(1:26);
    for i = 2:2:size(recall1,1)
        recall1(i) = (recall1(i-1) + recall1(i+1)) / 2;
        mT_IoU1(i) = (mT_IoU1(i-1) + mT_IoU1(i+1)) / 2;
    end
    
    recall2 = zeros((size(mT_IoU1,1)-1)*2+1,size(mT_IoU1,2));
    mT_IoU2 = zeros((size(mT_IoU1,1)-1)*2+1,size(mT_IoU1,2));
    recall2(1:2:end) = recall1(:);
    mT_IoU2(1:2:end) = mT_IoU1(:);
    for i = 2:2:size(recall2,1) % smooth lines
        recall2(i) = (recall2(i-1) + recall2(i+1)) / 2;
        mT_IoU2(i) = (mT_IoU2(i-1) + mT_IoU2(i+1)) / 2;
    end
    recall_values = cat(2,recall_values,recall2);
    mt_iou_values = cat(2,mt_iou_values,mT_IoU2);
end

x = 0:5:500;
figure,
subplot(1,2,1),
for r = 1:size(recall_values,2)
    plot(x,recall_values(:,r),line_style_set{r},'LineWidth',2),hold on,
    
end
xlabel('number of proposals'),
ylabel('recall'),
set(gca,'GridLineStyle', '-'),
set(gcf,'color',[1,1,1]),
% legend('Location','SouthEast'),
ylim([0,0.8]),
legend(legend_set),

subplot(1,2,2),
for r = 1:size(recall_values,2)
    plot(x,mt_iou_values(:,r),line_style_set{r},'LineWidth',2),hold on,
end
xlabel('number of proposals'),
ylabel('mT-IoU'),
set(gca,'GridLineStyle', '-'),
set(gcf,'color',[1,1,1]),
% legend('Location','SouthEast'),
legend(legend_set),
ylim([0,0.8]);

