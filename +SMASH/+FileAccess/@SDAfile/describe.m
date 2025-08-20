% desribe Revise record description
%
% This method changes the description associated with an archive record.
%   >> describe(archive,label,description);
% Descriptions are helpful for clarifying the contents of tersely labelled
% records.
%
% See also SDAfile, probe, select
%

%
% created October 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function describe(archive,label,description)

% handle input
assert(nargin>=3,'ERROR: insufficient input');
assert(ischar(description),'ERROR: invalid input');

% determine if archive is writable
setting=readAttribute(archive.ArchiveFile,'/','Writable');
if strcmpi(setting,'no')
    fprintf('Description cannot be changed because archive is not writable\n');
    return
end

% verify label
setname=['/' label];
try
    readAttribute(archive.ArchiveFile,setname,'Description');
catch
    error('ERROR: invalid label');
end

% update archive description
h5writeatt(archive.ArchiveFile,setname,'Description',description);
h5writeatt(archive.ArchiveFile,'/','Updated',datestr(now));

end