% READ Read file associated with a DIGfile object
%
% Syntax:
%    >> output=read(object);
% The output is a structure with the following fields.
%    -FileName
%    -Time
%    -Signal
%
% See also DIGfile, write
%

function output=read(object)

% error checking
assert(exist(object.FullName,'file')==2,...
    'ERROR: cannot probe file because it does not exist');

% call the reader
output.FileName=object.FileName;
[signal,time]=read_nts(object.FullName);
output.Time=time;
output.Signal=signal;
output.Format='dig';

end