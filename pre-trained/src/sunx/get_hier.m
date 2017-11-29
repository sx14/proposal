% 输入：相邻两帧
% 调用DeepFlow计算光流
% 调用MCG，取出单尺度hier
% 返回：flow H × W × 2 ;   hier curr_hier
function [hier, ucm] = get_hier(im1, flow)
% Load pre-trained Structured Forest model
sf_model = loadvar(fullfile(mcg_root, 'datasets', 'models', 'sf_modelFinal.mat'),'model');
% If the image is very big, to avoid running out of memory,
% we force 'fast', which does not upsample the image
% if size(image,1)*size(image,2)>2.5e6 % 2.5 megapixel
%     warning(['The image you are trying to segment using MCG might need too much memory because of its size (' num2str(size(image,1)) ',' num2str(size(image,2)) '). If you still want to try, comment lines 62-65 in im2mcg.m'])
% end
scales = [2, 1, 0.5];
[ucm2,ucms,times] = img2ucms(im1, sf_model, scales);
ucm = ucms(:,:,2);  % 取scale=1
hier = ucm2hier(ucm, flow);