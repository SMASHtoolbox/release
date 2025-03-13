% WRITE Write to a BlockFile object
%
% Syntax:
%    >> success=write(object,data,[format],[header]);
% The output is a logical flag indicating if the write was successful
% (true).
%
% see also BlockFile
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
elseif isnumeric(data)
    data={data};
end
assert(iscell(data),'ERROR: invalid data input');
for block=1:numel(data)
    assert(ismatrix(data{block}),'ERROR: invalid data input');
end

if (nargin<3) || isempty(format)
    format=cell(size(data));
elseif ischar(format)
    format={format};
    format=repmat(format,size(data));
elseif iscell(format) && numel(format)==1
    format=repmat(format,size(data));
end
assert(iscell(format) && numel(format)==numel(data),'ERROR: invalid format input');

if (nargin<4) || isempty(header)
    header=cell(size(data));
elseif ischar(header)
    header={header};
    header=repmat(header,size(data));
elseif iscell(header) && numel(header)==1   
    header=repmat(header,size(data));
end
assert(iscell(header) && numel(header)==numel(data),'ERROR: invalid header input');

% write the file
success=true;
for block=1:numel(data)     
    try
        %
        temp=header{block};
        if isempty(temp)
            fprintf(fid,'\n');
        elseif iscell(temp)        
            fprintf(fid,'%s\n',temp{:});
        elseif ischar(temp)
            fprintf(fid,'%s\n',temp);
        else
            error('');
        end
        %
        temp=format{block};
        if isempty(temp)
            [~,col]=size(data{block});
            temp=repmat('%+#g ',[1 col]);
        end
        temp=[temp '\n']; %#ok<AGROW>
        fprintf(fid,temp,transpose(data{block}));
    catch
        success=false;
    end
end

end