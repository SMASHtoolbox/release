% dumpStructure Dump structure to a cell array of strings
%
% This function dumps the contents of a structure to a cell array of
% strings.
%    output=dumpStructure(data);
% Each element of the output array corresponds to one structure field with
% the format 'name : value'.  Compound field names are shown for nested
% structures.
%
% See also General
%

%
% created February 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function output=dumpStructure(data,output,prefix)

% manage input
assert(isstruct(data),'ERROR: invalid data structure');

if nargin < 2
    output={};
end

if nargin < 3
    prefix='';
end

% process current level
name=fieldnames(data);
for n=1:numel(name)
    if isempty(prefix)
        new=name{n};
    else
        new=sprintf('%s.%s',prefix,name{n});
    end
    value=data.(name{n});
    if isobject(value)        
        value=convertObject(value);        
    end
    if isstruct(value)
        output=packtools.call('dumpStructure',value,output,new);
    else
        temp=evalc('disp(value)');
        temp=strtrim(temp);
        output{end+1}=sprintf('%s : %s',new,temp); %#ok<AGROW>
    end
end

end

function result=convertObject(data)

result=struct();
name=properties(data);
for n=1:numel(name)
    result.(name{n})=data.(name{n});
end

end