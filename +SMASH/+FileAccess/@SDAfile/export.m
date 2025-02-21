% export Export data from archive to file
%
% This method exports files stored in archive file to an external file.
%   >> export(object,filename,[new]);
% The optional third input "new" exports the stored file to a new name in
% the same directory as the archive file.  If omited, exported files use
% the same name as their original import (overwriting as necessary).
%
% See also SDAfile, import, extract, probe, select
%

%
% created October 8, 2013 by Tommy Ao (Sandia National Laboratories)
%
function export(object,filename,newfile)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');

if (nargin<3) || isempty(newfile)
    newfile=filename;
end

% transfer archive data to a file
data=extract(object,filename);
fid = fopen(newfile,'w');
fwrite(fid,data,'uint8');
fclose(fid);

end
