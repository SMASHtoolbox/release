% showExample Show example script
%
% This function shows an example script associated with the SMASH.  Script
% files are always located in a subdirectory named "examples" within
% the relevant package/class directory.
%    showExample(name); % [smashroot]/examples
%    showExample(name,location) % [smashroot]/[location]/examples
% Script files are stored with a *.m extension, copied to a local
% directory, and then displayed in the MATLAB editor.  Name requests with a
% *.m extension or no extension are coped as a standard script; using *.mlx
% converts the copied standard script to a live script.
% 
% See also SMASH.System
%

%
% creaed January 17, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function showExample(name,location)

% manage input
assert(nargin > 0,'ERROR: script name is required');

if (nargin < 2) || isempty(location)
    location='';
else
    index=(location == '/') | (location == '\');
    location(index)=filesep;
end
source=fullfile(smashroot,location,'examples');
assert(logical(exist(source,'dir')),'ERROR: invalid script location');

% look for script file
errmsg='ERROR: invalid script name';
[~,short,ext]=fileparts(name);
if isempty(ext)
    temp=dir(fullfile(source,[short '.*']));    
    assert(numel(temp) >= 1,errmsg);
    [~,~,ext]=fileparts(temp(1).name);
end

if strcmpi(ext,'.m')
    convert=false;
elseif strcmpi(ext,'.mlx')
    convert=true;
    ext='.m';
else
    error(errmsg);
end
source=fullfile(source,[short ext]);
assert(logical(exist(source,'file')),errmsg);

% copy valid script files
drop=(location == '+') | (location == '@');
new=location(~drop);
%new=fullfile(pwd,'examples',new);
new=fullfile(tempdir,'examples',new);
if ~exist(new,'dir')
    mkdir(new);
end

copyfile(source,new,'f');
name=fullfile(new,[short '.m']);
if convert
    temp=fullfile(new,[short '.mlx']);
    fig=msgbox('Creating local example file...please wait','Working');
    h=findobj(fig,'Style','pushbutton');
    delete(h);
    drawnow;
    matlab.internal.liveeditor.openAndSave(name,temp);
    delete(name);
    if ishandle(fig)
        delete(fig);
    end
    name=temp;
end

edit(name);

end