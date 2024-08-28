% replace Replace record data
%
% This method replaces data in an existing record with a new dataset of the
% same type and size.
%    replace(archive,label,new);
% NOTE: only numeric, logical, and character records can be replaced! 
%
% See also SDAfile, append, insert
%

%
% created November 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function replace(object,label,data)

% manage input
assert(nargin >=3,'ERROR: insufficient input');

[name,type]=probe(object);

found=false;
for n=1:numel(label)
    if strcmp(name{n},label)
        found=true;
        break
    end
end
assert(found,'ERROR: record not found');
switch type{n}
    case 'numeric'
        assert(isnumeric(data),'ERROR: numeric records can only be replaced with numeric data');
    case 'logical'
        assert(islogical(data),'ERROR: logical records can only be replaced with logical data');
        data=uint8(data);
    case 'character' 
        assert(ischar(data),'ERROR: character records can only be replaced with character data');
        data=uint8(data);
    otherwise
        error('ERROR: only primitive records can be replaced');
end

% perform insertion
location=sprintf('/%s/%s',label,label);
old=h5read(object.ArchiveFile,location);
assert(all(size(old)==size(data)),'ERROR: replacement size must match original size');
h5write(object.ArchiveFile,location,data);


end