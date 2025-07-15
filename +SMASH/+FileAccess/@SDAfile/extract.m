% extract Extract data from an archive
%
% This method extracts data from an archive file to a MATLAB variable.  The
% variable is selected by text label.
%    >> data=extract(archive,label);
%
% See also SDAfile, export, import, probe, select

%
% created October 9, 2014 by Daniel Dolan (Sandia National Labs)
%    -revised to match new SDA specification
%
function [data,metadata]=extract(archive,label)

% handle input
if (nargin<2) || isempty(label)
    label=select(archive);    
end

% verify label
if any(label=='/') || any(label=='\')
    error('ERROR: invalid label');
end

setname=['/' label];
try
    readAttribute(archive.ArchiveFile,setname,'RecordType');
    found=true;
catch
    found=false;
end
assert(found,'ERROR: label not found in archive');

% extract metadata
info=h5info(archive.ArchiveFile);
info=info.Groups;
for k=1:numel(info)
    if strcmp(info(k).Name,setname)
        info=info(k).Attributes;
        break;
    end
end

metadata=struct('Label',label);
for k=1:numel(info)
    metadata.(info(k).Name)=info(k).Value;
end
if isempty(metadata.Description)
   metadata.Description=''; 
end

% extract data based on type
switch readAttribute(archive.ArchiveFile,setname,'RecordType')
    case {'numeric','file'}
        data=extract_numeric(archive,repmat(setname,[1 2]));
        options.Deflate=readAttribute(archive.ArchiveFile,setname,'Deflate');
    case 'logical'
        data=extract_logical(archive,repmat(setname,[1 2]));
    case 'character'
        data=extract_character(archive,repmat(setname,[1 2]));
    case 'function'
        data=extract_function(archive,repmat(setname,[1 2]));
    case {'structure','split'}
        data=extract_structure(archive,setname);
    case 'structures'
        temp=extract_cell(archive,setname);
        data=repmat(temp{1},size(temp));
        for n=2:numel(temp)
            data(n)=temp{n};
        end
    case 'cell'
        data=extract_cell(archive,setname);
    case 'object'
        data=extract_object(archive,setname);              
    case 'objects'
        temp=extract_cell(archive,setname);
        data=repmat(temp{1},size(temp));
        for n=1:numel(temp)
            data(n)=temp{n};
        end
    otherwise
        error('ERROR: invalid record type detected');
end

end