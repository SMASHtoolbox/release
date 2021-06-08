% UNDER CONSTRUCTION
% convertFile Convert data file
%
% This method converts data from a text
function convertFile(object,file,format,record)

% manage input
if (nargin < 2) || isempty(file)
    [file,location]=uigetfile('*.*','Select data file');
    if isenumeric(file)
        return
    end
    file=fullfile(location,file);
else
    assert(ischar(file),'ERROR: invalid data file request');
    assert(logical(exist(file,'file')),'ERROR: data file not found');
end

if (nargin < 3) || isempty(format)
    try
        format=SMASH.FileAccess.determineFormat(file);
    catch
        return
    end
else
    assert(ischar(format),'ERROR: invalid file format');
    match=false;
    list=SMASH.FileAccess.SupportedFormats();
    for k=1:numel(list)
        if strcmpi(format,list{k})
            match=true;
            break
        end
    end
    assert(match,'ERROR: unsupported file format');
end

if nargin < 4
    record=[];    
end

% convert data
switch lower(format)
    case {'agilent' 'keysight'}
        convertKeysight(object.File,file,format,record);
    case 'tektronix'
        
    case 'lecroy'
        
    case 'column'
        
    otherwise
        error('ERROR: ''%s'' format not currently supported',format);
    
end

end