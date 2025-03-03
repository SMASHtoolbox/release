% writeSDA Write archive records
%
% This function writes records to a Sandia Data Archive (SDA) file.
% Individual records can be created from any MATLAB variable using a text
% label.
%    writeSDA(filename,label,variable);
%    writeSDA(filename,label,variable,description);
%    writeSDA(filename,label,variable,description,deflate);
% The optional input "description" assocates a text description (of
% arbitrary length) with the record.  The optional input "deflate" is an
% integer from 0 to 9 that controls the lossless compression level.
% NOTE: SDA records must have a unique label!  Specifying a label already
% present in the archive will generate an error.
%
% Calling this function with an asterisk:
%    writeSDA(filename,'*'); % no compression
%    writeSDA(filename,'*',deflate); % specify compression
% writes every variable in the current workspace to the archive file.
%
% Text and binary files can also be imported into the archive.
%    writeSDA(filename,'-import',insertfile); 
%    writeSDA(filename,'-import',insertfile,description);
%    writeSDA(filename,'-import',insertfile,description,deflate);
%
% See also probeSDA, readSDA, SDAbrowser
%

%
% created February 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function writeSDA(filename,label,varargin)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
try
    archive=SMASH.FileAccess.SDAfile(filename);
catch 
    error('ERROR: invalid archive file');
end

% write requested record(s)
if (nargin==2) && strcmp(label,'*')
    if nargin<3
        deflate=1;
    else
        deflate=varargin{1};
    end
    command=sprintf('SMASH.FileAccess.workspace2sda(''%s'',%d)',...
        filename,deflate);
    evalin('caller',command);
elseif strcmpi(label,'-import')
    source=varargin{1};
    assert(exist(source,'file')==2,'ERROR: insertion file not found');
    import(archive,source,varargin{:});
else
    assert(nargin >= 3,'ERROR: insufficient input');
    insert(archive,label,varargin{:});
end

end