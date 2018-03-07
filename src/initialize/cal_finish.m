% create a file named 'finish'
function cal_finish(path) 
fp=fopen([path,'/finish'],'w');
fclose(fp);