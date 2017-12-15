function output(path, file_name, content, type)
if strcmp(type,'img')
    imwrite(content, fullfile(path,file_name));
elseif strcmp(type, 'txt')
    fp=fopen(fullfile(path,file_name),'w');
    fprintf(fp,'%s',content);
    fclose(fp);
end
