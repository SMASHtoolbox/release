% RelativeFileName : determine the relative path between two directories
%
%
%
function func=RelativeFileName(filename,sourcepath)

if (nargin<2) || isempty(sourcepath)
    sourcepath=pwd;
end

filename=AbsoluteFileName(filename);
sourcepath=AbsoluteFileName(sourcepath);

[filepath,filename,ext]=fileparts(filename);
filename=[filename ext];
M=min(numel(filepath),numel(sourcepath));
match=(sourcepath(1:M)==filepath(1:M));
if numel(match)==0
    error('ERROR: no relative path can be generated');
end
start=sum(match)+1;

sourcepath=sourcepath(start:end);
if isempty(sourcepath)    
    relpath='.';
else
    if sourcepath(1)~=filesep
        sourcepath=[filesep sourcepath];
    end
    N=sum(sourcepath==filesep);
    relpath=['..' filesep];
    relpath=repmat(relpath,[1 N]);
end
func=fullfile(relpath,filepath(start:end),filename);