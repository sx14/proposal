f = figure('visible','off');
I = imread('000000.JPEG');
a = I;
a(:,:,:) = 0;
imshow(I),hold on;
h = imshow(a);
set(h,'alphaData',0.3);
f=getframe(gcf);
% imwrite(f.cdata,'a.jpeg');
close all;