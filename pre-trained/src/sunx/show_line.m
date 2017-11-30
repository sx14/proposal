function show_line(net, show, hiers, min_length, end_frame, org_imgs)
color = show.color_line;   % 颜色索引串号
all_length = net.lines(:,:,3);
all_lines = net.lines(:,:,1);
all_lines(all_length < min_length) = [];
long_lines = unique(all_lines);
X = sprintf('Long line sum: %d.',size(long_lines,2));
disp(X)
for i = 1:size(long_lines,2)
    for j =  1:end_frame
        hier = hiers{j};
        lines = net.lines(:,j,1);
        [sp,f,v] = find(lines == long_lines(i));
        if size(v,1) == 0
            continue;
        else
            mask_b = zeros(size(hier.leaves_part,1),size(hier.leaves_part,2));
            mask_b = ~get_binary_mask(sp, mask_b, hier, max(max(hier.leaves_part)));
            org_img = org_imgs{j,1};
            org_r = org_img(:,:,1);
            org_g = org_img(:,:,2);
            org_b = org_img(:,:,3);
            org_r(mask_b) = 0;
            org_g(mask_b) = 0;
            org_b(mask_b) = 0;
            org_img(:,:,1) = org_r;
            org_img(:,:,2) = org_g;
            org_img(:,:,3) = org_b;
            figure;
            imshow(org_imgs{j,1});hold on;  % 先放原图
            h = imshow(org_img);hold on;    % 带黑色mask的原图
            set(h,'alphaData',0.8);
        end
    end
    X = sprintf('Line: %d, continue?', long_lines(i));
    pause = input(X);
    close all;
end

function mask = get_binary_mask(sp, mask, hier, small_sp_sum)
for i = 1:size(sp)
    if sp(i) > small_sp_sum    % 组合过的sp
        % 递归将sp包含的像素位置置1
        conbine = hier.ms_struct(sp(i)-small_sp_sum);
        for i = 1:size(conbine.children,2)
            mask = get_binary_mask(conbine.children(1,i),mask,hier, small_sp_sum);
        end
    else    % 未组合过的sp
        % 直接置1
        sp_mask = hier.leaves_part == sp(i);
        mask(sp_mask) = 1;
    end
end
