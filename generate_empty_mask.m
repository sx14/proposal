a = imread('000210.JPEG');
mask = zeros(size(a));
mask(:) = 150;
a = mask * 0.7 + double(a) * 0.3;
imwrite(uint8(a),'000210_1.JPEG');
b = imread('000246.JPEG');
b = mask * 0.7 + double(b) * 0.3;
imwrite(uint8(b),'000246_1.JPEG');