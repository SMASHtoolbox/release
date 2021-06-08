% live2script Convert live script to a script file
%
% This function converts a live script file (*.mlx) to a standar script
% file.
%    live2script(source,destination);
% Omitting the input "source" prompts the user to select a live script.
% Omitting the second file generates the standard script in the same
% location as the live script.
%
% See also SMASH.System.convert, live2script
%

%
% created Feburary 11, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function live2script(source,destination)

if verLessThan('matlab',9.2)
    error('ERROR: this function requires MATLAB release 2017a or later');
end

% manage input
if (nargin < 1) || isempty(source)
    [source,location]=uigetfile({'*.mlx; *.MLX' 'MATLAB live scripts'},...
        'Select live script');
    if isnumeric(source)
        return
    end
    source=fullfile(location,source);
else
    assert(ischar(source),'ERROR: invalid live script');
    assert(logical(exist(source,'file')),...
        'ERROR: live script does not exist');
end

if (nargin < 2) || isempty(destination)
    [location,short,~]=fileparts(source);
    destination=fullfile(location,[short '.m']);
else
    [location,short,ext]=fileparts(destination);
    assert(strcmpi(ext,'.m'),'ERROR: invalid script file');
    if isempty(short)
        [~,short,~]=fileparts(source);
        destination=fullfile(location,[short ext]);
    end
    if exist(destination,'file')
        delete(destination);
    end
end

% perform conversion
matlab.internal.liveeditor.openAndConvert(source,destination);

end