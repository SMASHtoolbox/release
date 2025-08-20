% insertExample Insert example into toolbox
%
% This method inserts a MATLAB script into the "examples" directory of the
% SMASH toolbox.
%    Script.insertExample(filename);
% The input "filename" must be a standard or live script file.  Live
% scripts are automatically converted to standard scripts during insertion.
%
% Scripts can also be inserted into a subdirectory within the "examples"
% directory.
%    Script.insertExample(filename,subdir);
%
% See also Script, extractExample
%

%
% created January 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function insertExample(name,location)

% manage input
assert(nargin >= 1,'ERROR: no file name specified');
assert(packtools.call('Script.isScript',name),'ERROR: invalid file');

start=fullfile(smashroot,'examples');
if (nargin < 2) || isempty(location)
    location=start;
elseif ischar(location)
    location=fullfile(start,location);
    if ~exist(location,'dir')
        try
            mkdir(location);
        catch
            error('ERROR: invalid location');
        end
    end
else
    error('ERROR: invalid location');
end

% check for overwrite
[~,short,ext]=fileparts(name);
new=fullfile(location,[short '.m']);
if exist(new,'file')
    commandwindow();
    choice=input('Overwrite existing file? (y)es or (n)o: ','s');
    switch choice
        case {'y' 'yes'}
            delete(new);
        otherwise
            fprintf('   Example not inserted \n');
            return
    end
end

% copy script, converting as needed
[dirname,~,~]=fileparts(new);
log=fullfile(dirname,['.' short]);
fid=fopen(log,'w');
switch lower(ext)
    case '.m'
        copyfile(name,new);        
        fprintf(fid,'%s\n','standard');
    case '.mlx'
        fprintf('Converting live script to standard format...');
        packtools.call('Script.convert',name,new,'-overwrite');
        fprintf('done\n');
        fprintf(fid,'%s\n','live');
end
fclose(fid);

end