% store Store scan in an archive file
%
% This method stores LUNA scans in a Sandia Data Archive (*.sda) file.  In
% addition to a file name, the scan must be given a text label that is
% unique within the file.
%     >> store(object,filename,label);
% Multiple scans, as well as other records, may be located in a single
% file.
% 
% An optional description can be associated with the archived scan.
%     >> store(object,filename,label,description);
%
% See also LUNA, SMASH.FileAccess.writefile 
%

%
% created April 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function store(object,filename,label,description,deflate)

% handle input
assert(nargin>=3,'ERROR: file name and archive label are required')

if (nargin<4) || isempty(description)
    description=sprintf('%s object',class(object));
end

if (nargin<5) || isempty(deflate)
    deflate=9;
end

SMASH.FileAccess.writeFile(filename,label,object,description,deflate);

end