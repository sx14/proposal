output_path_set = {
    '/home/sunx/ICMR2018/output/x/exp_ours_match',
    '/home/sunx/ICMR2018/output/x/exp_ours',
    '/home/sunx/ICMR2018/output/x/exp_VEB',
    '/home/sunx/ICMR2018/output/x/exp_VMCG',
    '/home/sunx/ICMR2018/output/x/exp_FOD',
    '/home/sunx/ICMR2018/output/x/exp_SXD',
    '/home/sunx/ICMR2018/output/x/exp_SODP'
};

line_style_set = {'c','k','b','r','y','g','m'};

legend_set = {'ours','VEB','VMCG','FOD','SXD','SODP'};
draw_plot(output_path_set,line_style_set,legend_set);