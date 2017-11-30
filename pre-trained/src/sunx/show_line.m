function show_line(net, hiers, min_length, end_frame, org_imgs, mask_color, pause_time)
all_length = net.lines(:,end_frame,3);
all_lines = net.lines(:,end_frame,1);
all_lines((all_length < min_length)) = [];
long_lines = unique(all_lines);
X = sprintf('Long line sum: %d.',size(long_lines,1));
disp(X);
figure;
for i = 1:size(long_lines,1)
    for j =  end_frame:end_frame
        hier = hiers{j};
        lines = net.lines(:,j,1);
        [sp,~,v] = find(lines == long_lines(i));
        if size(v,1) == 0
            continue;
        else
            mask_b = zeros(size(hier.leaves_part,1),size(hier.leaves_part,2));
            mask_b = ~get_binary_mask(sp, mask_b, hier, max(max(hier.leaves_part)));
            org_img = org_imgs{j,1};
            org_r = org_img(:,:,1);
            org_g = org_img(:,:,2);
            org_b = org_img(:,:,3);
            org_r(mask_b) = mask_color(1);
            org_g(mask_b) = mask_color(2);
            org_b(mask_b) = mask_color(3);
            org_img(:,:,1) = org_r;
            org_img(:,:,2) = org_g;
            org_img(:,:,3) = org_b;
            imshow(org_imgs{j,1});hold on;  % 先放原图
            h = imshow(org_img);            % 带黑色mask的原图
            set(h,'alphaData',0.8)
        end
    end
    pause(pause_time);
%     if long_lines(i) > 700
%         X = sprintf('Line: %d, continue?', long_lines(i));
%         pause = input(X);
%     end
end
input('Close?');
close all;

function mask = get_binary_mask(sp, mask, hier, small_sp_sum)
for i = 1:size(sp)
    if sp(i) > small_sp_sum    % 组合过的sp
        % 递归将sp包含的像素位置置1
        conbine = hier.ms_struct(sp(i)-small_sp_sum);
        for j = 1:size(conbine.children,2)
            mask = get_binary_mask(conbine.children(1,j),mask,hier, small_sp_sum);
        end
    else    % 未组合过的sp
        % 直接置1
        sp_mask = hier.leaves_part == sp(i);
        mask(sp_mask) = 1;
    end
end
