% write Write tagged block
%
% This method writes a text block using a specified tag.
%    write(object,tag,data);
% The block format is determined automatically from the data type.
%    -Two-dimensional numeric and logical arrays are written directly.
%    -Table objects are written as comma-separated columns.
%    -Character arrays and cell arrays of characters are written as raw text.
%    -Flat structures are written as "name = value" pairs.
% 
% By default, this method will not write block data if the specified tag is
% already in use.  Passing an additional argument:
%    write(object,tag,data,'-overwrite');
% overrides this behavior.
%
% See also TagFile, probe, write
%

%
% created October 16, 2018 by Daniel Dolan (Sandia National Laboratories)
%

function varargout=write(object,tag,data,overwrite)

% manage input
assert(nargin >= 3,'ERROR: insufficient input');
assert(ischar(tag),'ERROR: invalid tag');

if (nargin < 4) || isempty(overwrite)
    overwrite=false;
else
    assert(strcmpi(overwrite,'-overwrite'),...
        'ERROR: invalid overwrite value');    
    overwrite=true;
end

% manage overwrite
list=probe(object);
conflict=false;
for n=1:numel(list)
    if strcmp(list{n},tag)        
        assert(overwrite,'ERROR: tag already in use');
        conflict=true;
    end
end

% write data to a temporary file
if islogical(data)
    data=int8(data);
end

ExcerptFile=tempname();
excerpt=fopen(ExcerptFile,'w');
CU1=onCleanup(@() fclose(excerpt));
if isnumeric(data) || islogical(data)
    assert(ismatrix(data) && isreal(data),...
        'ERROR: tag files only support 2D real numeric arrays');
    column=size(data,2);
    format=repmat('%g ',[1 column]);
    format=[format '\n'];
    fprintf(excerpt,format,transpose(data));
elseif istable(data)
    writetable(data,ExcerptFile);
elseif ischar(data) || iscellstr(data)
    if ischar(data)
        data=cellstr(data);
    end
    fprintf(excerpt,'%s\n',data{:});
elseif isstruct(data)    
    assert(isscalar(data),...
        'ERROR: tag files do not support structure arrays');
    name=fieldnames(data);
    for n=1:numel(name)
        fprintf(excerpt,'%s = ',name{n});
        value=data.(name{n});                
        if islogical(value)
            assert(isscalar(value),...
                'ERROR: pair blocks cannot use logical arrays');
            if value
                fprintf(excerpt,'true');
            else
                fprintf(excerpt,'false');
            end
        elseif isnumeric(value)
            value=reshape(value,1,[]);
            N=numel(value);
            value=sprintf('%g ',value);
            if N > 1
                value=['[' value ']']; %#ok<AGROW>
            end
            fprintf(excerpt,value);
        elseif ischar(value) || iscellstr(value) %#ok<*ISCLSTR>
            if iscellstr(value)
                value=char(value);
                value(:,end+1)=' '; %#ok<AGROW>
            end
            value=reshape(value,1,[]);
            fprintf(excerpt,value);            
        else
            error('ERROR: pair blocks do not support "%s" fields',...
                class(data));
        end
        fprintf(excerpt,'\n');
    end
else
    error('ERROR: tag files do not support "%s" data',class(data));
end

% merge temporary and existing files
fclose(excerpt);
excerpt=fopen(ExcerptFile,'r');
new={};
while ~feof(excerpt)
    new{end+1}=fgetl(excerpt); %#ok<AGROW>
end
fclose(excerpt);

excerpt=fopen(ExcerptFile,'w');

temp=read(object,'-header');
if ~isempty(temp)
    fprintf(excerpt,'%s\n',temp{:});
end

list=probe(object);
for n=1:numel(list)
    if n > 1
        fprintf(excerpt,'\n');
    end
    fprintf(excerpt,'[%s]\n',list{n});
    if strcmp(list{n},tag)
        fprintf(excerpt,'%s\n',new{:});
    else
        data=read(object,list{n},'raw');
        fprintf(excerpt,'%s\n',data{:});
    end
end

if ~conflict
    fprintf(excerpt,'\n[%s]\n',tag);
    fprintf(excerpt,'%s\n',new{:});
end

% move merged file onto original
target=fullfile(object.PathName,object.FileName);
copyfile(ExcerptFile,target,'f');

% manage output
if nargout > 0
    varargout{1}=new;
end

end