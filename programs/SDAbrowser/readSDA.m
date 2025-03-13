% readSDA Read archive records
%
% This function reads records from a Sandia Data Archive (SDA) file.
% Individual records are accessed by their label.
%    variable=readSDA(filename,label);
%    [variable,type,description]=readSDA(filename,label);
% Label wildcards are permitted and may return multiple variables (with
% types and descriptions, if requested) as a cell array.
%
% Calling this function with no output:
%    readSDA(filename,label); % load a specific record
%    readSDA(filename,'*'); % load all records
% loads data records as variables in the calling workspace.  These
% variables are named after the archive labels as closely as possible,
% subject to MATLAB variable restrictions (e.g., spaces are convereted to
% underscores).  WARNING: this approach overwrites existing variables using
% the same name!
% 
% 
% NOTE: SDA files can contain primitive/compound records (numeric, etc.) as
% well as external records, such as data files.  These files are exported
% from the archive instead of loaded into MATLAB.
%
% See also probesda, writeSDA, SDAbrowser
%

%
% created February 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=readSDA(filename,record)

% manage input
assert(nargin >= 1,'ERROR: no archive file specified');
try
    archive=SMASH.FileAccess.SDAfile(filename);
catch 
    error('ERROR: invalid archive file');
end

if nargin < 2
    record='*';
end
assert(ischar(record),'ERROR: invalid record name');


% read requested record(s)   
[label,type,description]=probe(archive,record);
if isempty(label)
    error('ERROR: invalid record requested');
elseif any(regexp(record,'*'))
    % allow loose matches
elseif numel(label) > 1
    keep=false(size(label));
    for m=1:numel(label)
        if strcmp(label{m},record)
            keep(m)=true;
            break
        end
    end
    assert(any(keep),'ERROR: no exact record match.  Use wildcards to read partial matches');
    label=label(keep);   
end

variable=cell(size(label));
for m=1:numel(label)
    switch type{m}
        case 'file'
            export(archive,label{m});
            variable{m}=fullfile(pwd,label{m});
            fprintf('Exporting archived file : %s\n',label{m});
        case 'split'
            error('ERROR: split files cannot be read into MATLAB');
        otherwise
            variable{m}=extract(archive,label{m});
    end
end

% manage output
if nargout==0
    for m=1:numel(variable)
        switch(type{m})
            case {'file' 'split'}
                continue
            otherwise
                name=convertName(label{m});                
        end
        if isempty(name)
            name=sprintf('SDArecord%d',m);
        end
        assignin('caller',name,variable{m});
    end
else
    if numel(variable)==1
        variable=variable{1};
        type=type{1};
        description=description{1};
    end
    varargout{1}=variable;
    varargout{2}=type;
    varargout{3}=description;
end

end

function name=convertName(name)

for m=1:numel(name)
    if isvarname(name(m))
        break
    end
end
name=name(m:end);

keep=true(size(name));
for m=1:numel(name)
    if isvarname(name(1:m))
        continue
    elseif name(m) == ' '
        name(m)='_';
    else
        keep(m)=false;
    end
end
name=name(keep);

end