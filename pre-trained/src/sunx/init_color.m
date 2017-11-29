function color_v = init_color(color_sum)
step = ceil(color_sum^(1/3));
color_i = 1;
color_v = zeros(color_sum,4);
for i = 1:step
    for j = 1:step
        for k = 1:step
            color_v(color_i,1) = round(255/step) * i - 1;
            color_v(color_i,2) = round(255/step) * j - 1;
            color_v(color_i,3) = round(255/step) * k - 1;
            color_i = color_i + 1;
        end
    end 
end