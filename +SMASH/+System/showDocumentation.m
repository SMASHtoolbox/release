% UNDER CONSTRUCTION
% showDocumentation Show published documentation
%
% This function shows formatted documentation associated with the SMASH
% toolbox.  Documentation files are scripts displayed in HTML format. These
% files are always located in a subdirectory name "doc" within the relevant
% package/class directory.
%
% See also SMASH.System
%

%
% creaed March 28, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function showDocumentation(name,location)

% manage input
assert(nargin > 0,'ERROR: script name is required');

if (nargin < 2) || isempty(location)
    location=evalin('caller','mfilename(''fullpath'')');
    location=fileparts(location);
end

source=fullfile(location,'doc');
assert(logical(exist(source,'dir')),'ERROR: invalid script location');

% look for script file
errmsg='ERROR: invalid script name';
[~,short,ext]=fileparts(name);
if isempty(ext)
    temp=dir(fullfile(source,[short '.*']));    
    assert(numel(temp) >= 1,errmsg);
    [~,~,ext]=fileparts(temp(1).name);
end

assert(strcmpi(ext,'.m'),errmsg);
source=fullfile(source,[short ext]);
assert(logical(exist(source,'file')),errmsg);

% copy valid script files
drop=(location == '+') | (location == '@');
new=location(~drop);
new=fullfile(tempdir,'doc',new);
if ~exist(new,'dir')
    mkdir(new);
end
copyfile(source,new,'f');

new=fullfile(new,[short ext]);
publish(new,'format','html','evalCode',false);           
target=fileparts(new);
target=fullfile(target,'html',[short '.html']);
web(target);

end