% sda2mat Convert archive to a MAT file
% 
% This function converts an archive (*.sda file) to a *.mat file,
% which is compatible with MATLAB's load command.
%    sda2mat(archive,matfile)
% The user is prompted to select omitted and/or empty file names
%
% See also SMASH.FileAccess, mat2sda
%

%
% created November 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function sda2mat(archive,file)

% manage input
if (nargin < 1) || isempty(archive)
    sf=SMASH.MUI.SelectFile;
    sf.Title='Select archive file';
    sf.Filter='*.sda';
    sf.EnableFilter='on';
    sf.FileControls='off';
    sf.HiddenControl='off';
    archive=launch(sf);
    if isnumeric(archive)
        return
    end
end
assert(exist(archive,'file')==2,'ERROR: archive file not found');
[~,~,ext]=fileparts(archive);
assert(strcmpi(ext,'.sda'),'ERROR: invalid archive extension');

if (nargin < 2) || isempty(file)
    sf=SMASH.MUI.SelectFile;
    sf.Title='Select MAT file';
    sf.Filter='*.mat';
    sf.EnableFilter='on';
    sf.FileControls='off';
    sf.HiddenControl='off';
    archive=launch(sf);
    if isnumeric(archive)
        return
    end
end
if exist(file,'file')
    choice=questdlg('Overwrite existing MAT file?', ...
        'Overwrite?', ...
        'Yes', 'No', 'No');
    if ~strcmpi(choice,'yes')
        return
    end
end
[~,~,ext]=fileparts(file);
assert(strcmpi(ext,'.mat'),'ERROR: invalid MAT file extension');

% load and transfer data
name=SMASH.FileAccess.sda2workspace(archive);
save(file,name{:});

end