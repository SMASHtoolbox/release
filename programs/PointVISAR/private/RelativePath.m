% RelativePath : determine the relative path between two directories
%
%
%
function func=RelativePath(targetpath,sourcepath)

% input check
if nargin<1
    error('Error: no target path specified');
end
if nargin<2
    sourcepath='';
end

% default value(s)
if isempty(sourcepath)
    sourcepath=pwd;
end

% enforce correct file separators for current system
kk=find((targetpath=='/')|(targetpath=='\'));
targetpath(kk)=filesep;
kk=find((sourcepath=='/')|(sourcepath=='\'));
sourcepath(kk)=filesep;

% error checking
if ~isdir(targetpath)
    message=sprintf('Error: %s \n is not a directory!',targetpath);
    error(message)
end
if ~isdir(sourcepath)
    message=sprintf('Error: %s \n is not a directory!',sourcepath);
    error(message)
end

% extract drive and directory information for source and target
[sourcedrive,sourcedir]=dirparts(sourcepath);
[targetdrive,targetdir]=dirparts(targetpath);

if ~strcmp(sourcedrive,targetdrive)
    func=targetpath;
    message=sprintf('Error: source/target drives do not match-- no relative path is possible!');
    error(message);
end

N=min([numel(sourcedir) numel(targetdir)]);
for level=1:N
    if strcmp(sourcedir{level},targetdir{level})
        continue
    else
        level=level-1;
        break
    end
end

uplevel=numel(sourcedir)-level;
if uplevel==0
    func=['.' filesep];
else
    func=['..' filesep];
    func=repmat(func,[1 uplevel]);
end

downlevel=level+1;
for ii=downlevel:numel(targetdir)
    func=[func targetdir{ii} filesep];
end

if func(end)==filesep
    func=func(1:end-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [drive,list]=dirparts(directory)

% terminate directory with a file separator for convenience
if directory(end)~=filesep
    directory(end+1)=filesep;
end

% find the file separators
start=find(directory==filesep);

% extract drive information
drive=directory(1:start(1)-1);
if isempty(drive)
    drive='root'; % unix systems
end

% extract directory names
for ii=1:length(start)-1
    list{ii}=directory(start(ii)+1:start(ii+1)-1);
end