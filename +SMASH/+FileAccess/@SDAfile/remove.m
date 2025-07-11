% remove Remove record from an archive
%
% This method removes one or more records from an archive file.
%    >> remove(archive,label1,label2,...);
% CAUTION: record removal can be slow (depending on the remaining archive
% contents) and is irreversible!
%
% See also SDAfile, probe
%

%
% created October 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function remove(archive,varargin)

% handle input
assert(nargin>=2,'ERROR: insufficient input');

persistent ShowWaitbar
if isempty(ShowWaitbar)
    ShowWaitbar=true;
end
switch varargin{1}
    case '-show'
        ShowWaitbar=true;
        return
    case '-hide'
        ShowWaitbar=false;
        return
end

% determine if archive is writable
setting=readAttribute(archive.ArchiveFile,'/','Writable');
if strcmpi(setting,'no')
    fprintf('Record(s) cannot be removed because archive is not writable\n');
    return
end
created=readAttribute(archive.ArchiveFile,'/','Created');

% move kept records to a temporary file
[pathname,filename,ext]=fileparts(archive.ArchiveFile);
filename=fullfile(pathname,[filename '__temporary__' ext]);
new=SMASH.FileAccess.SDAfile(filename,'overwrite');

label=probe(archive);
if ShowWaitbar
    h=waitbar(0,'Progress');
    set(h,'WindowStyle','modal');
end
for k=1:numel(label)
    if any(cellfun(@(s) strcmp(label{k},s),varargin))
        continue
    end
    setname=['/' label{k}];
    deflate=readAttribute(archive.ArchiveFile,setname,'Deflate');
    data=extract(archive,label{k});
    description=readAttribute(archive.ArchiveFile,setname,'Description');
    insert(new,label{k},data,description,deflate);
    h5writeatt(filename,setname,'RecordType',...
        readAttribute(archive.ArchiveFile,setname,'RecordType'));
    if ShowWaitbar
        waitbar(k/numel(label),h);
    end
end
if ShowWaitbar
    delete(h);
end

% replace original file
movefile(new.ArchiveFile,archive.ArchiveFile,'f');
h5writeatt(archive.ArchiveFile,'/','Created',created);

end