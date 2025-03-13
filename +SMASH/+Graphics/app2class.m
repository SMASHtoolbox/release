% app2class Convert app to class file
%
% This function converts a *.mlapp file (generated by the App Designer) to
% a class definition *.m file.  The input syntax is:
%    app2class(source,destination).
% If no inputs are specified, the user is prompted to select a *.mlapp
% file.  Omitting the second input places the converted file in the current
% directory.
%
% See also SMASH.Graphics
%

%
% created September 26, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function app2class(source,destination)

% manage input
if (nargin < 1) || isempty(source)
    [name,location]=uigetfile({'*.mlapp;*.MLAPP'; 'App files (*.mlapp)'},...
        'Select app file');
    if isnumeric(name)
        return
    end
    source=fullfile(location,source);
else
    assert(ischar(source) && (exist(source,'file') == 2),...
        'ERROR: invalid app file');
end

if (nargin < 2) || isempty(destination)
    destination=pwd;
else
    assert(ischar(destination) && (exist(destination,'dir') == 7),...
        'ERROR: invalid destination');
end

% raw conversion
OldDiary=get(0,'DiaryFile');
if strcmpi(get(0,'Diary'),'on')
    DiaryWasOn=true;
    diary off
else
    DiaryWasOn=false;
end

TempFile=tempname();
set(0,'DiaryFile',TempFile);

diary(TempFile);
diary on;
type(source);
diary off;

set(0,'DiaryFile',OldDiary);
if DiaryWasOn
    diary on
end

% clean up converted file
[~,name,~]=fileparts(source);
target=fullfile(destination,[name '.m']);
copyfile(TempFile,target);

end