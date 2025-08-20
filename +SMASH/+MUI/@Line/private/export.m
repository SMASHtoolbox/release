function export(~,~,target)

% gather line data
x=get(target,'XData');
y=get(target,'YData');
data=[x(:) y(:)];

% prompt user for file name
[fname,pname]=uiputfile('*.*','Select export file');
if isnumeric(fname)
    return
end
filename=fullfile(pname,fname);

% store data
fid=fopen(filename,'w');
fprintf(fid,'%#+.6g %#+.6g\n',transpose(data));
fclose(fid);


end