function show_frame(image, hier)
figure;
set(gcf, 'position', [1000 1080 900 1080]);
subplot(2,1,1)
imshow(image);
mask = zeros(size(hier.leaves_part,1),size(hier.leaves_part,2),3);
small_sp_sum = max(max(hier.leaves_part));
sp_sum = max(max(hier.ms_matrix));
colors = init_color(sp_sum);
for i = 1:sp_sum
    if i == small_sp_sum+1
        input('All small sp, continue?');
    end
    mask = fill_color(i, mask, colors(i,:),hier, small_sp_sum);
    subplot(2,1,2);
    imshow(uint8(mask));
%     if i > small_sp_sum
    if i > 0
        X = sprintf('SP %d.',i);
        input(X);
    end
end


function mask = fill_color(sp, mask, color, hier, small_sp_sum)
if sp > small_sp_sum    % 组合过的sp
    % 递归填充颜色
    combine = hier.ms_matrix;
    info = combine(sp-small_sp_sum,:);
    grandsons = info(1:length(info) - 1);
    for i = 1:length(grandsons)
        mask = fill_color(grandsons(i),mask,color,hier, small_sp_sum);
    end
else    % 未组合过的sp
    % 直接填充颜色
    sp_mask = hier.leaves_part == sp;
    mask_R = mask(:,:,1);
    mask_G = mask(:,:,2);
    mask_B = mask(:,:,3);
    mask_R(sp_mask) = color(1);
    mask_G(sp_mask) = color(2);
    mask_B(sp_mask) = color(3);
    mask(:,:,1) = mask_R;
    mask(:,:,2) = mask_G;
    mask(:,:,3) = mask_B;
end




