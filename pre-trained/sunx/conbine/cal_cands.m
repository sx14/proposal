% function cal_cands(lines, hiers)
% line_label = lines(:,:,1);
% max_line_label = double(max(max(line_label)));
% line_info = zeros(max_line_label,3);    % start_frame,end_frame,length
% for f=1:size(line_label,2) % 遍历每一帧
%     if line_label(1,f,1) == 0   % 到头了
%         break;
%     end
%     sp = 1;
%     while(line_label(sp,f) > 0)     % 遍历每一个sp
%         line = line_label(sp,f);
%         if line_info(line,1) == 0   % 这个串第一次出现
%             line_info(line,1) = f;  % 标记起始帧
%             line_info(line,2) = f;  % 更新结束帧
%         else
%             line_info(line,2) = f;  % 更新结束帧
%         end
%         sp = sp+1;
%     end
% end
% line_info(:,3) = line_info(:,2) - line_info(:,1) + 1;   % 计算串长
% short_lines = find(line_info(:,3) < 10);            % 所有不超过10帧的串
% line_conbine_mat = sparse(max_line_label,max_line_label);
% for i = 1:length(hiers)     % 每一帧
%     curr_lines = line_label(:,i);% 每一帧上的超像素-串号
%     cands = hiers{i}.cands; % 单帧上的组合结果
%     for j = 1:size(cands,1) % 每一个cand，对串投票
%         cand = cands(j,:);
%         cand = cand(cand > 0);
%         for m = 1:length(cand)-1    % 每个cand包含的sp
%             l1 = curr_lines(cand(m));
%             for n = m+1:length(cand)
%                 l2 = curr_lines(cand(n));
%                 line_conbine_mat(l1,l2) = line_conbine_mat(l1,l2) + 1;
%                 line_conbine_mat(l2,l1) = line_conbine_mat(l2,l1) + 1;
%             end
%         end
%     end
% end
% % remove 短串
% line_conbine_mat(short_lines,:) = 0;
% line_conbine_mat(:,short_lines) = 0;
% line_info(short_lines,:) = 0;
% line_conbine_mat(line_conbine_mat < 10) = 0;
% temp = sum(line_conbine_mat);
% bundle_cands = cell(length(find(temp > 0)),1);
% bundle_label = 1;
% for i = 1:size(line_conbine_mat,1)
%     t = line_conbine_mat(i,:);
%     line_conbine = find(t > 0);
%     if ~isempty(line_conbine)
%         bundle_cands{bundle_label} = [i line_conbine];
%         bundle_label = bundle_label + 1;
%     end
% end
% a = 1;
% 
% 
