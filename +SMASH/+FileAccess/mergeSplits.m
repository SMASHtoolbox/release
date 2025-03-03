% mergeSplits Restore complete file from a set of split SDA files
%
% This function merges  a set of split SDA files into a complete file.  All
% split files must be available, but only one name needs to be passed to
% this function.  For example, suppose the original file "mydata" was split
% into "mydata_file1.sda" and "mydata_file2.sda".
%    >> mergeSplits('mydata_file1.sda');
%    >> mergeSplits('mydata_file2.sda');
% Either call restores the the original file "mydata" as long as both split
% files are present.
% 
% By default, this function does not overwrite existing files.  If there is
% a name conflict, the user is prompted to select a new file name.  The
% restored file name can also be manually specified as a second function
% input.
%    >> mergeSplits(filename,target);
%
% See also FileAccess, splitFile
%

%
% created October 20, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function mergeSplits(source,target)

% handle input
assert(nargin>=1,'ERROR: insufficient input');

if iscell(source)
    source=source{1};
end

if nargin<2
    target='';
end

% test source file
assert(exist(source,'file')==2,'ERROR: file not found');
try
    archive=SMASH.FileAccess.SDAfile(source);
    data=extract(archive,'split file');
catch
    error('ERROR: invalid split file');
end

% verify that all split files are present
[pathname,~,~]=fileparts(source);
files=data.SplitFiles;
N=numel(files);
for k=1:N
    [~,short,ext]=fileparts(files{k});
    files{k}=fullfile(pathname,[short ext]);
    assert(exist(files{k},'file')==2,...
        'ERROR: one or more split files are missing');
end

% read split files into target file
if isempty(target)
    target=fullfile(pathname,data.OriginalName);
end
if exist(target,'file')
    [~,~,ext]=fileparts(target);
    ext=sprintf('*%s',ext);
    [filename,pathname]=uiputfile(ext,'Select merged file name');
    if isnumeric(pathname)
        return
    end
    target=fullfile(pathname,filename);
end
%assert(~exist(target,'file'),'ERROR: target file already exists');

fid=fopen(target,'w');
finishup = onCleanup(@() fclose(fid));
for k=1:N
    archive=SMASH.FileAccess.SDAfile(files{k});
    data=extract(archive,'split file');
    fwrite(fid,data.Bytes,'uint8');    
end


end