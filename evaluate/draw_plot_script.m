% output_path_set = {
%     '/home/sunx/ICMR2018/output/x/exp_ours_match',
%     '/home/sunx/ICMR2018/output/x/exp_ours',
%     '/home/sunx/ICMR2018/output/x/exp_VEB',
%     '/home/sunx/ICMR2018/output/x/exp_VMCG',
%     '/home/sunx/ICMR2018/output/x/exp_FOD',
%     '/home/sunx/ICMR2018/output/x/exp_SXD',
%     '/home/sunx/ICMR2018/output/x/exp_SODP'
% };
% 
% line_style_set = {'c','k','b','r','y','g','m'};
% 
% legend_set = {'ours','VEB','VMCG','FOD','SXD','SODP'};
% draw_plot(output_path_set,line_style_set,legend_set);

output_path_set = {
    '/home/sunx/ICMR2018/output/exp/exp_param_flow/flow_0.7',
    '/home/sunx/ICMR2018/output/exp/exp_param_flow/flow_0.6',
    '/home/sunx/ICMR2018/output/x/exp_ours_match',
    '/home/sunx/ICMR2018/output/exp/exp_param_flow/flow_0.4',
    '/home/sunx/ICMR2018/output/exp/exp_param_flow/flow_0.3'
};

% output_path_set = {
%     '/home/sunx/ICMR2018/output/exp/exp_param_adjacent/0.7/result',
%     '/home/sunx/ICMR2018/output/exp/exp_param_adjacent/0.4/result',
%     '/home/sunx/ICMR2018/output/x/exp_ours_match',
%     '/home/sunx/ICMR2018/output/exp/exp_param_adjacent/0.1/result',
%     '/home/sunx/ICMR2018/output/exp/exp_param_adjacent/0/result'
% };

line_style_set = {'b','r','k','g','m'};

% legend_set = {'ours','VEB','VMCG','FOD','SXD','SODP'};
legend_set = ['b';'r';'k';'g';'m'];
draw_plot(output_path_set,line_style_set,legend_set);