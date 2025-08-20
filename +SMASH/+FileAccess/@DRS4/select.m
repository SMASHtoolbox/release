% hidden static method
function [file,format]=select(file)

if (nargin < 1) || isempty(file)
    pattern={'*.xml;*.XML;*.dat;*.DAT' 'DRS4 data files'};
    [file,location]=uigetfile(pattern,'Select data file');
    if isnumeric(file)
        return
    end    
    file=fullfile(location,file);
    [~,~,ext]=fileparts(file);
else
    assert(isfile(file),'ERROR: requested file does not exist');
    [~,~,ext]=fileparts(file);
    assert(strcmpi(ext,'.xml') || strcmpi(ext,'.dat'),...
        'ERROR: invalid DRS4 file extension');  
end

switch lower(ext)
    case '.xml'
        format='text';
    case '.dat'
        format='binary';
end

end