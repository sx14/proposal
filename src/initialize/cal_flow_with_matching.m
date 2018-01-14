video_path = '/home/sunx/flow_test';
tool_path = '/home/sunx/flow_test';
image1_path = fullfile(video_path,'sintel1.png');
image2_path = fullfile(video_path,'sintel2.png');
deep_flow_path = fullfile(tool_path,'deepflow2-static');
deep_match_path = fullfile(tool_path,'deepmatching-static');
cmd = ['.',deep_match_path,' ',image1_path,' ',image2_path,' | ','.',deep_flow_path,' ',image1_path,' ',image2_path, ' -match -sintel'];
disp(cmd);
system(cmd);