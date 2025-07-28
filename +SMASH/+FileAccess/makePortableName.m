% makePortableName Make file name for any operating system
%
% This function makes a portable file name valid on any operating system.
%    result=makePortableName(suggestion);
% The output "result" is a character array or scalar string based on the
% input "suggestion"; when no suggestion is provided, "result" is derived
% frome the current date and time.  All problematic characters are replaced
% by underscores so that the result contains only alphanumber characters
% (0-9, A-Z, and a-z), hypens, periods, and undercores.
%
% Requesting second output:
%    [result,change]=makePortableName(suggestion);
% returns the number of underscore replacements needed to make the portable
% file name.
%
% See also SMASH.FileAccess
%
function [out,change]=makePortableName(in)

% manage input
if (nargin < 1) || isempty(in)
    stamp=datevec(datetime('now'));
    stamp=round(stamp);
    in=sprintf('file%04d%02d%02dT%02d%02d%02d',stamp);    
else
    if isStringScalar(in)
        in=char(in);
    else
        assert(ischar(in),'ERROR: invalid file name');
    end
end

% process suggestion
out=in;
change=0;
valid=uint8([45 46 48:57 65:90 95 97:122]);
for n=1:numel(out)
    if any(uint8(out(n)) == valid)
        continue
    end
    out(n)='_';
    change=change+1;    
end


end