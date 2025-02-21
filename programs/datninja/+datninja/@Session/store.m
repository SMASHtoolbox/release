function store(object,file)

% manage input
if (nargin < 2) || isempty(file)
    
    [file,location]=uiputfile({'*.sda' 'Sandia Data Archive (*.sda) files'},...
        'Select session file');
    if isnumeric(file)
        return
    end
    file=fullfile(location,file);
end

% overwrite existing file
if exist(file,'file')
    delete(file);
end

archive=SMASH.FileAccess.SDAfile(file);
insert(archive,'datninja session',object,'Bitmap image with reference and data points',2);
archive.Writable=false;

end