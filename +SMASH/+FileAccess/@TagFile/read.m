% read Read tagged block
%
% This method reads the text block associated with a particular tag.
%    out=read(object,tag); % 'raw' format
%    out=read(object,tag,format);  
% By default, the output "out" is a cell array of character strings
% representing the raw block data.  Additional block formats can be
% specified.
%    -'text' combines adjacent lines into a cell array of strings, using
%    empty lines to separate array elements (i.e., paragraphs).
%    -'array' processes the block as a 2D numeric array.  Brackets, commas,
%    and semicolons should *not* be used.
%    -'table' processes the block as a MATLAB table, using commas a column
%    separators.  Mixed data (numbers and text) are permitted.
%    -'pair' interprets the block as a series of "name = value" statements.
%     Values are initially interpreated a numeric MATLAB statements,
%     reverting to characters as needed.
%
% All lines prior to the first block can be read with a reserved tag.
%    out=read(object,'-header'); 
% Format options are *not* supported for the header.
%
% See also TagFile, probe, write
%

%
% created October 16, 2018 by Daniel Dolan (Sandia National Laboratories)
%

function out=read(object,tag,format)

% probe file
[list,start,stop]=probe(object);
file=fullfile(object.PathName,object.FileName);
source=fopen(file,'r');
CU1=onCleanup(@() fclose(source));

if isempty(start)
    HeaderLines=0;
    while ~feof(source)
        fgetl(source);
        HeaderLines=HeaderLines+1;
    end
    frewind(source);
else
    HeaderLines=start(1)-1;
end

% manage tag input
assert(nargin >= 2,'ERROR: no tag specified');
if isstring(tag)
    tag=char(tag);
else
    assert(ischar(tag),'ERROR: invalid tag');
end
tag=reshape(tag,1,[]);

if strcmpi(tag,'-header')
    out=cell(HeaderLines,1);
    out{1}='';
    for n=1:HeaderLines
        out{n}=fgetl(source);
    end
    return
end

match=false;
for n=1:numel(list)
    if strcmp(list{n},tag)
        match=true;
        start=start(n);
        stop=stop(n);
        break
    end
end
assert(match,'ERROR: tag %s not found',tag);

% manage format input
if (nargin < 3) || isempty(format)
    format='raw';
else
    if isstring(format)
        format=char(format);
    end
    assert(ischar(format),'ERROR: invalid block type');
    
end

% read block
out=cell(stop-start,1);
for k=1:stop
    temp=fgetl(source);
    if k <= start
        continue
    end
    out{k-start}=strtrim(temp);
end

while numel(out) > 1
    if isempty(out{1})
        out=out(2:end);
    elseif isempty(out{end})
        out=out(1:end-1);
    else
        break
    end
end


if strcmpi(format,'raw')
    return
end

% process block
in=out;
if strcmp(format,'text')
    out={''};
    k=1;
    for n=1:numel(in)
        temp=strtrim(in{n});
        if isempty(temp)
            if ~isempty(out)
                k=k+1;
                out{k}='';
            end
            continue
        elseif isempty(out{k})
            out{k}=temp; 
        else
            out{k}=[out{end} ' ' temp];
        end
    end
    if isempty(out{end})
        out=out(1:end-1);
    end
    return
elseif strcmp(format,'pair')
    out=struct();
    for n=1:numel(in)
        if isempty(in{n})
            continue
        end  
        index=find(in{n} == '=',1,'first');
        assert(~isempty(index),...
            'ERROR: block "%s" cannot be read as name/value pairs',tag);
        name=strtrim(in{n}(1:index-1));
        if ~isvarname(name)
            name=matlab.lang.makeValidName(name);
        end
        raw=strtrim(in{n}(index+1:end));
        temp=str2num(raw); %#ok<ST2NM>
        if isempty(temp)    
            out.(name)=raw;
        else
            out.(name)=temp;
        end
    end
    return
end

ExcerptFile=tempname();
excerpt=fopen(ExcerptFile,'w');
fprintf(excerpt,'%s\n',out{:});
fclose(excerpt);

switch format
    case 'array'
        fopen(ExcerptFile,'r');
        CU2=onCleanup(@() fclose(excerpt));
        temp=fgetl(excerpt);        
        [~,columns]=sscanf(temp,'%g');
        frewind(excerpt);
        temp=fscanf(excerpt,'%g',[columns inf]);
        next=fscanf(excerpt,'%s');
        assert(isempty(next),...
            'ERROR: block "%s" cannot be read as an array',tag);
        out=transpose(temp);
        return
    case 'table'
         out=readtable(ExcerptFile);            
         return
end

error('ERROR: "%s" is not a valid format',format);

end