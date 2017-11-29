function show = show_frame(show, net, hier, frame)
figure;
mask = zeros(size(hier.leaves_part,1),size(hier.leaves_part,2),3);
small_sp_sum = max(max(hier.leaves_part));
color_line = show.color_line;   % 颜色索引串号
line_color = show.line_color;   % 串号索引颜色
length = net.lines(:,frame,3);  % 当前帧上所有串的长度
long_line_index = find(length > floor(frame/2));    % 长度超过一半帧数的串的index(sp)
all_lines = net.lines(:,frame,1);               % 当前帧上所有串号
long_lines = all_lines(long_line_index');       % 当前帧上长串的串号
lost_line_color_index = line_color;
lost_line_color_index(long_lines') = 0;         % 剩下的是断掉的串的颜色
lost_line_color_index(lost_line_color_index == 0) = [];
color_line(lost_line_color_index,4) = 0;     % 将断掉的串的颜色设置为未分配状态
for i = 1:size(long_lines,1)
    if i == (small_sp_sum+1)
        pause = input('All small sp, continue?');
    end
    color_index = line_color(long_lines(i,1));
    if color_index == 0 % 新串未分配颜色
        for j = 1:size(color_line,1)
            if color_line(j,4) == 0 % 成功分配颜色
                color_index = j;
                color_line(j,4) = long_lines(i,1);
                line_color(long_lines(i,1)) = j;
                break;
            end
        end
    end
    if color_index > 0 % 颜色分配成功
        sp = long_line_index(i);
        mask = fill_color(sp, mask, color_line(color_index,1:3),hier, small_sp_sum);
        show.line_color = line_color;
        show.color_line = color_line;
        imshow(uint8(mask)), title('Mask')
        if i >= (small_sp_sum+1)
            X = sprintf('SP %d.',sp);
            pause = input(X);
        end
        
    end
end
% figure;
% imshow(uint8(mask)), title('Mask')


function mask = fill_color(sp, mask, color, hier, small_sp_sum)
if sp > small_sp_sum    % 组合过的sp
    % 递归填充颜色
    conbine = hier.ms_struct(sp-small_sp_sum);
    for i = 1:size(conbine.children,2)
        mask = fill_color(conbine.children(1,i),mask,color,hier, small_sp_sum);
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




