function hier_set = cal_img_pro_scores(hier_set,sp_flow_info)
    for f = 1:length(hier_set)
        hier = hier_set{f};
        mcg_scores = hier.scores;
        motion_scores = get_motion_scores(hier.cands,sp_flow_info{f});
        scores = 0.7 * mcg_scores + 0.3 * motion_scores;
        hier.scores = scores;
        hier_set{f} = hier;
    end
end

