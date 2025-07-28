% UNDER CONSTRUCTION
% 
%
function trimBytes(file,bytes)

% manage input
assert(nargin == 2,'ERROR: invalid number of inputs')

if isStringScalar(file)
    file=char(file);    
else
    assert(ischar(file),'ERROR: invalid file name');    
end
try
    list=dir(file);
catch
    error('ERROR: file not found');
end

assert(isnumeric(bytes) && isscalar(bytes) && (bytes > 0),...
    'ERROR: invalid number of bytes');
if bytes >= list.bytes    
    return
end
bytes=ceil(bytes);

% use Java
jFile=java.io.RandomAccessFile(file, 'rw');
jFile.setLength(bytes);
jFile.close();

end