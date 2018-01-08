function ucm = get_ucm(leaves_part, distance)
height = size(leaves_part, 1);
width = size(leaves_part, 2);
ucm = zeros(size(leaves_part) * 2 + 1);
for i = 1:size(leaves_part,1)
    for j = 1:size(leaves_part,2)
        r_allow = (j + 1) <= width;
        d_allow = (i + 1) <= height;
        if r_allow  % 不是最右侧，可以填写边缘强度
            r = distance(leaves_part(i,j), leaves_part(i,j+1));
            ucm(2*i, 2*j+1) = r;
        end 
        if d_allow
            d = distance(leaves_part(i, j), leaves_part(i+1,j));
            ucm(2*i+1, 2*j) = d;
        end
        if r_allow && d_allow
            r_d = distance(leaves_part(i,j), leaves_part(i+1, j+1));
            ucm(2*i+1, 2*j+1) = r_d;
        end
    end
end
ucm(:,1) = ucm(:,2);
ucm(:,size(ucm,2)) = ucm(:,size(ucm,2) - 1);
ucm(1,:) = ucm(2,:);
ucm(size(ucm,1),:) = ucm(size(ucm,1)-1,:);



%     % 水平扫一遍
%     for j = 1: size(leaves_part,1)
%         for k = 1:size(leaves_part,2) - 1
%             leaf1 = leaves_part(j,k);
%             leaf2 = leaves_part(j,k+1);
%             if leaf1 ~= leaf2
%                 ucm(j,k) = distance(leaf1,leaf2);
%             end
%         end
%     end
%     % 竖直扫一遍
%     for k = 1: size(leaves_part,2)
%         for j = 1:size(leaves_part,1) - 1
%             leaf1 = leaves_part(j,k);
%             leaf2 = leaves_part(j+1,k);
%             if leaf1 ~= leaf2
%                 ucm(j,k) = distance(leaf1,leaf2);
%             end
%         end
%     end