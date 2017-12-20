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
% scales = [2, 1, 0.5];
scales = 0.5;
[~,ucm,~] = img2ucms(im1, sf_model, scales);
% ucm = ucms(:,:,2);  % 取scale=1
ucm(ucm < 0.1) = 0;
hier = ucm2hier(ucm,flow);
% figure;
% imshow(imdilate(ucm,strel(ones(3))),[]), title(['ucm']);
% input('next?');
% close all;
% ============================ 加candidate ======================
% n_hiers = size(ucm,3);
% lps = [];   % leaves_parts
% ms  = cell(n_hiers,1);  % merging-sequence
% ths = cell(n_hiers,1);  % threshold
% for ii=1:n_hiers
%     % Transform the UCM to a hierarchy
%     curr_hier = ucm2hier(ucm(:,:,ii),flow);
%     ths{ii}.start_ths = curr_hier.start_ths';
%     ths{ii}.end_ths   = curr_hier.end_ths';
%     ms{ii}            = curr_hier.ms_matrix;
%     lps = cat(3, lps, curr_hier.leaves_part);
% end
% % Load pre-trained pareto point
% pareto_n_cands = loadvar(fullfile(mcg_root, 'datasets', 'models', 'scg_pareto_point_train2012.mat'),'n_cands');
% [f_lp,f_ms,cands,start_ths,end_ths] = full_cands_from_hiers(lps,ms,ths,pareto_n_cands);
% % Hole filling and complementary proposals
% if ~isempty(f_ms)
%     [cands_hf, cands_comp] = hole_filling(double(f_lp), double(f_ms), cands); %#ok<NASGU>
% else
%     cands_hf = cands;
%     cands_comp = cands; %#ok<NASGU>
% end
% cands = cands_hf;
% leaves_num = max(max(f_lp));
% f_ms(1:leaves_num,:) = [];
% f_ms = f_ms - double(leaves_num);
% cands(cands > 0) = cands(cands > 0) - double(leaves_num);
% start_ths(1:leaves_num) = [];
% end_ths(1:leaves_num) = [];
% parent_col = size(f_ms,2);
% ms_struct(size(f_ms,1)) = struct('parent',[],'children',[]);
% for i = 1:size(f_ms,1)
%     ms_struct(i).parent = f_ms(i,parent_col);
%     children = f_ms(i,1:parent_col-1);
%     ms_struct(i).children = children(children ~= 0);
% end
% 
% b_feats = compute_base_features(f_lp, f_ms, ucm);
% b_feats.start_ths = start_ths;
% b_feats.end_ths   = end_ths;
% b_feats.im_size   = size(f_lp);
% 
% % Level of overlap to erase duplicates
% J_th = 0.95;
% % Filter by overlap
% red_cands = mex_fast_reduction(cands-1,b_feats.areas,b_feats.intersections,J_th);
% 
% hier.leaves_part = f_lp;
% hier.ms_struct = ms_struct;
% hier.start_ths = start_ths;
% hier.end_ths = end_ths;
% hier.cands = red_cands;