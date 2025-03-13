% renameFiles Mapped file renaming
%
% This function renames a group of files using a map file.
%    renameFiles(location,map);
% The input "location" indicates the directory where the files are located.
%  The default location is the current directory.
%
%  The input "map" is the name of a text file containing "old >> new"
%  statements.  For example:
%     fileA.txt >> data1.txt
% renames 'fileA.txt' to 'data1.txt' if such a file exists in the specified
% location.
%
% Subsequent calls to this function can omit the second input if the map is
% to be reused.
%    renameFiles(location);
% 
% See also SMASH.System
%


%
% created April 11, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function renameFiles(varargin)

% manage input
if (nargin < 1) || isempty(varargin{1})
    location=pwd;
else
    location=varargin{1};
    assert(logical(exist(location,'dir')),'ERROR; invalid directory');
end

persistent map
if (nargin < 2) || isempty(varargin{2})
    assert(~isempty(map),'ERROR: not map file specified');
    map=varargin{2};
else
    assert(logical(exist(varargin{2},'file')),'ERROR: invalid map file');
    map=varargin{2};
end

% parse map file
fid=fopen(map,'r');
CU1=onCleanup(@() fclose(fid));

pattern=[];
while ~feof(fid)
    temp=strtrim(fgetl(fid));
    if isempty(temp) || (temp(1) == '%')
        continue
    end
    index=strfind(temp,'>>');
    if isempty(index)
        fprintf('Ignorning invalid statement: %s\n',temp);
        continue
    end
    pattern(end+1).Old=strtrim(temp(1:index-1)); %#ok<AGROW>
    pattern(end).New=strtrim(temp(index+2:end));   
end

% rename files
start=pwd;
CU2=onCleanup(@() cd(start));
cd(location);
for m=1:numel(pattern)
    if any(pattern(m).Old == '*')
        error('ERROR: wildcards not supported (yet)');
    end
    if exist(pattern(m).Old,'file')
        movefile(pattern(m).Old,pattern(m).New);
    end
end

end