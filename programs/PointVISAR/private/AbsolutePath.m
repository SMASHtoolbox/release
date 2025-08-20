% AbsolutePath : determine absolute path of a file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=AbsolutePath(filename,sourcepath)

% input check
if nargin<1
    error('Error: no file name specified');
end
if nargin<2
    sourcepath='';
end

% default value(s)
if isempty(sourcepath)
    sourcepath=pwd;
end

% enforce correct file separators for current system
kk=find((filename=='/')|(filename=='\'));
filename(kk)=filesep;
kk=find((sourcepath=='/')|(sourcepath=='\'));
sourcepath(kk)=filesep;

% save starting location
OldDir=pwd;

% move to file location
cd(sourcepath);
[pathstr,name,ext]=fileparts(filename);
if isempty(pathstr)
    % do nothing
else
    if isdir(pathstr)
        cd(pathstr); % may contain a relative path
    else        
        cd(OldDir);
        message=sprintf('Error: %s \n is not a valid directory with respect to %s \n',...
            pathstr,sourcepath);
        error(message);
    end
end

% determine absolute path
name=[name ext];
func=fullfile(pwd,name);

% return to starting location
cd(OldDir);