% mat2sda Convert MAT file to an archive
% 
% This function converts a MAT file (created with MATLAB's save command) to
% a *.sda archive.
%    mat2sda(matfile,archive)
% The user is prompted to select ommitted and/or empty file names.
%
% See also SMASH.FileAccess, sda2mat
%

%
% created November 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function mat2sda(file,archive)

% manage input
if (nargin < 1) || isempty(file)
    sf=SMASH.MUI.SelectFile;
    sf.Title='Select MAT file';
    sf.Filter='*.mat';
    sf.EnableFilter='on';
    sf.FileControls='off';
    sf.HiddenControl='off';
    file=launch(sf);
    if isnumeric(file)
        return
    end
end
assert(exist(file,'file')==2,'ERROR: archive file not found');

if (nargin < 2) || isempty(archive)
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
if exist(archive,'file')
    choice=questdlg('Overwrite existing archive?', ...
        'Overwrite?', ...
        'Yes', 'No', 'No');
    if ~strcmpi(choice,'yes')
        return
    end
   delete(archive);
end
[~,~,ext]=fileparts(archive);
assert(strcmpi(ext,'.sda'),'ERROR: invalid archive extension');

% load and transfer data
data=load(file);
name=fieldnames(data);
for m=1:numel(name)
    description=sprintf('MAT variable "%s"',name{m});
    SMASH.FileAccess.writeFile(archive,name{m},data.(name{m}),description);
end

end