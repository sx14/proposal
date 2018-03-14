% 输入：相邻两帧
% 调用DeepFlow计算光流
% 调用MCG，取出单尺度hier
% 返回：flow H × W × 2 ;   hier curr_hier
function [hier, ucm] = get_hier(im1, flow)
% Load pre-trained Structured Forest model
sf_model = loadvar(fullfile(mcg_root, 'datasets', 'models', 'sf_modelFinal.mat'),'model');
scales = 1;
[~,ucm,~] = img2ucms(im1, sf_model, scales);
ucm = ucm - 0.1;
ucm(ucm < 0) = 0;
max_edge_weight = max(max(ucm));
if max_edge_weight > 0
    ucm = ucm / max_edge_weight;
end

% show UCM:
% figure;
% imshow(imdilate(ucm,strel(ones(3))),[]), title(['ucm']);
% input('next?');
% close all;

n_hiers = size(ucm,3);
lps = [];   % leaves_parts
ms  = cell(n_hiers,1);  % merging-sequence
ths = cell(n_hiers,1);  % threshold
for ii=1:n_hiers
    % Transform the UCM to a hierarchy
    curr_hier = ucm2hier(ucm(:,:,ii),flow);
    ths{ii}.start_ths = curr_hier.start_ths';
    ths{ii}.end_ths   = curr_hier.end_ths';
    ms{ii}            = curr_hier.ms_matrix;
    lps = cat(3, lps, curr_hier.leaves_part);
end
pareto_n_cands = loadvar(fullfile(mcg_root, 'datasets', 'models', 'scg_pareto_point_train2012.mat'),'n_cands');
[f_lp,f_ms,cands,start_ths,end_ths] = full_cands_from_hiers(lps,ms,ths,pareto_n_cands);

b_feats = compute_base_features(f_lp, f_ms, ucm);
b_feats.start_ths = start_ths;
b_feats.end_ths   = end_ths;
b_feats.im_size   = size(f_lp);

leaves_num = max(max(f_lp));
f_ms = f_ms(leaves_num + 1:end,:);
f_ms(f_ms > leaves_num) = f_ms(f_ms > leaves_num) - double(leaves_num);

hier.b_feats = b_feats;
hier.leaves_part = f_lp;
hier.ms_matrix = f_ms;