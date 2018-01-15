function [flow_ucm,leaf_flow_norm] = get_flow_ucm(grid_leaves,mcg_ucm,flow)
    leaf_flow_norm = cal_leaf_flow_norm(grid_leaves(2:2:end, 2:2:end),flow);
    [row,col] = size(mcg_ucm);
    flow_ucm = zeros(size(mcg_ucm));
    for r = 1:size(mcg_ucm,1)   % scan horizontally
        for c = 1:size(mcg_ucm,2)
            if mcg_ucm(r,c) > 0
                if c-1 > 0 && c+1 <= col
                    leaf1 = grid_leaves(r,c-1);
                    leaf2 = grid_leaves(r,c+1);
                    if leaf1 ~= leaf2 && leaf1 ~= 0 && leaf2 ~= 0
                        flow_ucm(r,c) = abs(leaf_flow_norm(leaf1)-leaf_flow_norm(leaf2));
                    end
                end 
            end
        end
    end
    
    for c = 1:size(mcg_ucm,2)   % scan vertically
        for r = 1:size(mcg_ucm,1)
            if mcg_ucm(r,c) > 0
                if r-1 > 0 && r+1 <= row
                    leaf1 = grid_leaves(r-1,c);
                    leaf2 = grid_leaves(r+1,c);
                    if leaf1 ~= leaf2 && leaf1 ~= 0 && leaf2 ~= 0
                        flow_ucm(r,c) = abs(leaf_flow_norm(leaf1)-leaf_flow_norm(leaf2));
                    end
                end 
            end
        end
    end
    max_edge_weight = max(max(flow_ucm));
    if max_edge_weight ~= 0
        flow_ucm = flow_ucm / max_edge_weight;
    end
end


