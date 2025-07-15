% generateArray Create a collection array
%
% This *static* method generates an array of collection objects.
%    object=Collection.generateArray(N);
% The input "N" determines the number of elements in the 1xN output
% "object".  The default value is 1.
%
% An optional second input:
%    object=Collection.generateArray(N,format);
% broadcasts specified file format (character/string/cell array) to each
% object element.
%
% Composite objects can be made with standard array operations.  For
% example:
%    A=Collection.generateArray(1,'keysight');
%    A.Pattern='*.h5';
%    B=Collection.generateArray(1,'tektronix');
%    B.Pattern='*.wfm';
%    preview([A B]);
% looks for all Keysight files (first record only) followed by all
% Tektronix files.
%
% See also Collection, preview, read
%
function object=generateArray(elements,format)

% create array
try
    object(elements)=packtools.call('Collection');
catch
    error('ERROR: invalid number of elements');
end
if nargin < 2
    return
end

% apply format as needed
for n=1:elements
    try
        object(n).Format=format;
    catch ME
        throwAsCaller(ME);
    end
end

end