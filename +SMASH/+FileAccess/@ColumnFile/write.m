% WRITE Write to a ColumnText object
%
% Syntax:
%    >> success=write(object,data,[format],[header]);
% The output is a logical flag indicating if the write was successful
% (true).
%
% see also ColumnFile
%

%
function success=write(object,data,format,header)

if exist(object.FullName,'file')
    message{1}='Target file already exists.';
    message{2}='Should it be overwritten?';
    choice=questdlg(message,'Overwrite file','Yes','No','No');
    if strcmp(choice,'Yes')
        delete(object.FullName);
    else
        return
    end
end
fid=fopen(object.FullName,'w');     
finish=onCleanup(@() fclose(fid));

if (nargin<2) || isempty(data)
   return % leave file empty 
end

numcol=size(data,2);
if (nargin<3) || isempty(format)
    format=repmat('%+#g ',[1 numcol]);
    format=[strtrim(format) '\n'];
end

if (nargin<4) || isempty(header)
    header={};
elseif ischar(header)
    header={header};
end
assert(iscell(header),'ERROR: invalid header input');

% write the file
try
    fprintf(fid,'%s\n',header{:});
    fprintf(fid,format,transpose(data));
    success=true;
catch
    success=false;
end

end