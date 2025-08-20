% append Append text to file
%
% This method appends text to a File object.
%    append(object,data);
% The input "data" can be a character string or a cell array of character
% strings; in the latter case, each element is written on a separate line.
%
% See also File
%

%
% created October 17, 2018 by Daniel Dolan
%
function append(object,data)

% manage input
assert(nargin >= 2,'ERROR: nothing to append');
if ischar(data)
    data={data};
else
    assert(iscellstr(data),'ERROR: cannot append this type of data');
end

% open and append file
target=fullfile(object.PathName,object.FileName);
try
    fid=fopen(target,'a');
catch
    error('ERROR: cannot append file');
end

fprintf(fid,'%s\n',data{:});
fclose(fid);

end