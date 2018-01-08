% scale:用于smooth操作的前后帧数
function [proposals] = smooth_boxes(proposals)
    scale = 2;
    interval = 1 + 2 * scale;
    for p = 1:length(proposals)
        proposal = proposals{p};
        boxes = proposal.boxes;
        for i = scale+1 : size(boxes,1)-scale
            curr_box = boxes(i,:);
            curr_center_x = floor((curr_box(1) + curr_box(2)) / 2);
            curr_center_y = floor((curr_box(3) + curr_box(4)) / 2);
            start_frame = i - scale;
            end_frame = i + scale;
            w_h_sum = zeros(2,1);
            for f = start_frame : end_frame
                box = boxes(f,:);
                w = box(1) - box(2);
                h = box(3) - box(4);
                w_h_sum = w_h_sum + [w;h];
            end
            avg_w_h_half = floor(w_h_sum / interval / 2);
            curr_box(1) = curr_center_x + avg_w_h_half(1);
            curr_box(2) = curr_center_x - avg_w_h_half(1);
            curr_box(3) = curr_center_y + avg_w_h_half(2);
            curr_box(4) = curr_center_x - avg_w_h_half(2);
            boxes(f,:) = curr_box;
        end
        proposal.boxes = boxes;
        proposals{p} = proposal;
    end
end

