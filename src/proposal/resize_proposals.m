function proposals = resize_proposals(proposals,org_height,org_width,resize_height,resize_width)
    resize_ratio = double(max(org_width,org_height)) / double(max(resize_width,resize_height));
    for i = 1:length(proposals)
        proposal = proposals{i};
        proposal.boxes = round(proposal.boxes * resize_ratio);
        proposals{i} = proposal;
    end
end

