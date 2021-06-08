% script2live Convert script file to a live script
%
% This function converts a standard script file (*.m) to a live script
% (*.mlx).
%    script2live(source,destination);
% Omitting the input "source" prompts the user to select a script file.
% Omitting the second file generates the live script in the same location
% as the source file.
%
% See also SMASH.System.convert, live2script
%

%
% created Feburary 11, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function script2live(source,destination)

if verLessThan('matlab',9.2)
    error('ERROR: this function requires MATLAB release 2017a or later');
end

% manage input
if (nargin < 1) || isempty(source)
    [source,location]=uigetfile({'*.m; *.M' 'MATLAB script files'},...
        'Select script file');
    if isnumeric(source)
        return
    end
    source=fullfile(location,source);
else
    assert(ischar(source),'ERROR: invalid script file');
    assert(logical(exist(source,'file')),...
        'ERROR: script file does not exist');
end

if (nargin < 2) || isempty(destination)
    [location,short,~]=fileparts(source);
    destination=fullfile(location,[short '.mlx']);
else
    [location,short,ext]=fileparts(destination);
    assert(strcmpi(ext,'.mlx'),'ERROR: invalid live document');
    if isempty(short)
        [~,short,~]=fileparts(source);
        destination=fullfile(location,[short ext]);
    end
    if exist(destination,'file')
        delete(destination);
    end
end

% perform conversion
matlab.internal.liveeditor.openAndSave(source,destination);

end
