function export(object,file,format)

% manage input
if (nargin < 2) || isempty(file)
    [file,location]=uiputfile('*.*','Select export file');
    if isnumeric(file)
        return
    end
    file=fullfile(location,file);
else
    assert(ischar(file) && logical(exist(file,'file')),...
        'ERROR: invalid image file');
end

if (nargin < 3) || isempty(format)
    format='%#+.6g %#+.6g';
end
if ~strcmp(format(end-1:end),'\n')
    format=[format '\n'];
end


% perform export
fid=fopen(file,'w');
fprintf(fid,'Source image: %s\n',object.ImageFile);
fprintf(fid,'(x,y) data exported %s\n',datestr(now));
fprintf(fid,format,transpose(object.DataTable(:,3:4)));
fclose(fid);

end