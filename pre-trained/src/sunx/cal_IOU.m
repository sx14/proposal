function match_sp_iou_mat = cal_IOU(last_sp_pixels, new_sp_pixels, match_sp)
% 上一帧中所有超像素包含的像素个数，sp*1，复制使其尺寸与match_sp相同
last_sp_pixels_rep = repmat(last_sp_pixels,1,size(new_sp_pixels,1));
% 新一帧中所有超像素包含的像素个数，sp*1，复制使其尺寸与match_sp的转置相同
new_sp_pixels_rep = repmat(new_sp_pixels,[1,size(last_sp_pixels)]);
U = last_sp_pixels_rep + new_sp_pixels_rep';
match_sp_iou_mat = match_sp ./ (U - match_sp);

