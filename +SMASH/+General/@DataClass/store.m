% store Store object in an archive
%
% This method stores an object in a Sandia Data Archive (SDA) file.
%     >> store(object,filename,label);
% The file name must have a *.sda extension (case insensitive).  The object
% label must be a text string not already present in the archive file.
% Labels can use any number ASCII characters except slashes.
%
% An optional description can be associated with the stored object.
%     >> store(object,filename,description);
% The input "description" can be any number of ASCII characters.  The
% default description is '(classname) object'.
%
% Lossless compression is controlled with a deflate input.
%     >> store(object,filename,description,deflate); 
% Vavlid "deflate" values are integers from 0 (no compression) to 9
% (maximum compression).  The default value is 1.
%
% See also DataClass, FileAccess.SDAfile
%

%
% created February 12, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function store(object,filename,label,description,deflate)

% handle input
assert(nargin>=3,'ERROR: file name and archive label are required')

if (nargin<4) || isempty(description)
    description=sprintf('%s object',class(object));
end

if (nargin<5) || isempty(deflate)
    deflate=1;
end

archive=SMASH.FileAccess.SDAfile(filename);
insert(archive,label,object,description,deflate);
h5writeatt(filename,['/' label],'Class',class(object));
h5writeatt(filename,['/' label],'RecordType','object');

end