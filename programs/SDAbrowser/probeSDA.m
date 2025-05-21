% probeSDA Reveal archive contents
%
% This function reveals the contents of a Sandia Data Archive (SDA) file.
% When called with no output:
%    probeSDA(filename); 
% the archive's contents are printed in the command window.  Specific
% information from the archive is returned by requesting output.
%    [label,type,description,status]=probeSDA(filename);
% 
% See also readSDA, writeSDA, SDAbrowser
%

%
% created February 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=probeSDA(filename)

% manage input
assert(nargin >= 1,'ERROR: no archive file specified');
try
    assert(exist(filename,'file') == 2,'');
    archive=SMASH.FileAccess.SDAfile(filename);
catch 
    error('ERROR: invalid archive file');
end

% probe file as requested
if nargout==0
    probe(archive);
else
    varargout=cell(1,nargout);
    [varargout{:}]=probe(archive);
end

end