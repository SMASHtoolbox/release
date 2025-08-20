% convert Convert between standard and live scripts
%
% This methods converts between standard and live script files.
% The general syntax is:
%    script.convert(source,target);
% The input "source" must be the name of a MATLAB script file.  Standard
% scripts (*.m) are converted to live scripts (*.mlx) and vice versa.
% Function and class definition files *cannot* be converted.
%
% Omitting the second input places a converted file in the same location as
% the source file with the same base name.
%    script.convert('myscript.m') % create 'myscript.mlx'
%    script.convert('myscript.mlx') % create 'myscript.m'
% Implicit naming requires the first input to have a valid file extension.
% File extensions are managed automatically for explicit naming.
%    script.convert('myscript.m','backup') % create 'backup.mlx'    
%
% Users are asked to overwrite exisiting files if the converted file name
% (explicitly specified or implicitly generated) is already in use.
% Automatic overwrites can be specified with a third input argument.
%    script.convert(source,target,'-overwrite'); % explicit naming
%    script.convert(source,'','-overwrite'); % implicit naming
%
% See also script
%

%
% created January 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function convert(source,target,overwrite)

% manage input
assert(nargin >= 1,'ERROR: no source file specfiied');
[srcdir,srcfile,ext]=fileparts(source);
if isempty(srcdir)
    srcdir=pwd;
end
switch lower(ext)
    case '.m'
        mode='m2mlx';
        test=packtools.call('Script.isScript',source);
        assert(test,'ERROR: invalid source file');  
    case '.mlx'
        mode='mlx2m';
    otherwise
        error('ERROR: invalid source file');
end
source=fullfile(srcdir,[srcfile ext]);

if (nargin < 2) || isempty(target)
    switch mode
        case 'm2mlx'
            ext='.mlx';
        case 'mlx2m'
            ext='.m';
    end
    target=fullfile(srcdir,[srcfile ext]);
end
assert(ischar(target),'ERROR: invalid target file');
[tardir,tarfile,ext]=fileparts(target);
switch mode
    case 'm2mlx'
        ext='.mlx';
    case 'mlx2m'
        ext='.m';
end
target=fullfile(tardir,[tarfile ext]);

if (nargin < 3) || isempty(overwrite)
    overwrite=false;
elseif islogical(overwrite)
    % do nothing
elseif strcmpi(overwrite,'-overwrite')
    overwrite=true;
else
    error('ERROR: invalid overwrite value');
end

if exist(target,'file')
    if ~overwrite
        commandwindow();
        choice=input('Overwrite existing file? (y or no): ','s');
        switch choice
            case {'y' 'yes'}
                delete(target);
            otherwise
                fprintf('   File not converted\n');
                return
        end
    end
end

% convert file
switch mode
    case 'm2mlx'
        matlab.internal.liveeditor.openAndSave(source,target);
    case 'mlx2m'
        matlab.internal.liveeditor.openAndConvert(source,target);
end

end