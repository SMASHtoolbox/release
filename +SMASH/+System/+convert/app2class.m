% app2class Convert App Designer file to a class definition
%
% This function converts a *.mlapp file (as created by the App Designer) to
% a *.m class definition.
%    app2class(source); 
% Omitting the input "source" prompts the user to select a *.mlapp file.
%
% The converted class file is saved in the current directory by default,
% overwriting any existing file with that name.  The file can also be
% written to a specified location:
%    app2class(source,target);
% 
% See also SMASH.System.convert
%

%
% created February 10, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function app2class(source,target)

if verLessThan('matlab', '8.4')
    error('ERROR: this function requires MATLAB release 2014b or later');
end

% manage input
if (nargin < 1) || isempty(source)
    [source,location]=uigetfile({'*.mlapp; *.MLAPP' 'MATLAB apps'},...
        'Select MATLAB app file');
    if isempty(source)
        return
    end
    source=fullfile(location,source);
else
    assert(exist(source,'file') == 2,'ERROR: requested app not found');
end
[~,short,ext]=fileparts(source);
assert(strcmpi(ext,'.mlapp'),'ERROR: invalid app name');

if (nargin < 2) || isempty(target)
    target=fullfile(pwd,[short '.m']);    
else
    [~,~,ext]=fileparts(target);
    assert(strcmpi(ext,'.m'),'ERROR: invalid class file name');
end
[location,~,~]=fileparts(target);
if ~isempty(location) && (exist(location,'dir') ~= 7)
    mkdir(location);
end
try
    fid=fopen(target,'w');
catch
    error('ERROR: invalid target file');
end

% extract class definition
command=sprintf('type(''%s'')',source);
code=evalc(command);
fprintf(fid,'%c',code);
fclose(fid);

end