% import Import file into archive
%
% This method imports an external file into an archive file.  The imported
% file is automatically labelled by name.  An optional description and
% deflate level can be specified.
%   >> import(object,filename,[description],[deflate]);
%
% See also SDAfile, export, insert, probe, select
%

% created October 8, 2013 by Tommy Ao (Sandia National Laboratories)
% revised October 9, 2014 by Daniel Dolan
%    -altered method to match revised SDA specification
%
function import(object,filename,description,deflate)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');

if (nargin<3) || isempty(description)
    description='';
end

if (nargin<4) || isempty(deflate)
    deflate=0;
end

% determine if archive is writable
setting=readAttribute(object.ArchiveFile,'/','Writable');
if strcmpi(setting,'no')
    fprintf('File not imported because archive is not writable\n');
    return
end

%% read data from file
fid=fopen(filename,'r');
data=fread(fid,[1 Inf],'uint8');
data=uint8(data);
fclose(fid);
[~,fname,ext] = fileparts(filename);
shortname=[fname ext];

% insert file into archive
insert(object,shortname,data,description,deflate);
h5writeatt(object.ArchiveFile,['/' shortname],'RecordType','file');

end
