% edit Edit text file
%
% This method opens the referenced text file in the MATLAB editor.
%    edit(object);
%
% See also File
%

function edit(object)

try
    edit(fullfile(object.PathName,object.FileName));
catch
    error('ERROR: cannot edit file');
end

end