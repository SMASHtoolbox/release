% verifyFileName Verify file name
%
% This function determines if a text string is a valid file name.
%    result=verifyFileName(name);
% The output "result" is a logical value.
%
% See also System
%

%
%
%
function result=verifyFileName(name)

% manage input
assert(nargin > 0,'ERROR: no name specified');

% perform tests
result=false;
if ~ischar(name)
    return
end

location=tempdir();
while true
    [name,temp,ext]=fileparts(name);
    if isempty(temp) && isempty(ext)
        break        
    end
    % need to test Windows--what happens to the drive letter?
    temp=fullfile(location,[temp ext]);
    try
        fid=fopen(temp,'w');
        fclose(fid);
        delete(temp);
    catch
        return
    end    
end

result=true;

end