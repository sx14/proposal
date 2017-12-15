function test(img_label)
colormap = zeros(256,3);
colormap(:,1) = randperm(256);
colormap(:,2) = randperm(256);
colormap(:,3) = randperm(256);
colormap = (colormap - 1) / 255.0;
[h,w] = size(img_label);
img_region = zeros(h,w,3);
for x = 1:h
    for y = 1:w
        for k = 1:3
            img_region(x,y,k) = colormap(img_label(x,y),k);
        end
    end
end
figure,imshow(img_region);

