% fixSlash Replace slashes for local OS
% 
% This function replaces forward/backward slashes for compliance with the
% local operating system.
%    out=fixSlash(in);
% All '/' and '\' characters are replaced with the platform file separator:
% backward slash on Windows and forward slash for everything else.
%
% See also SMASH.System
%
function out=fixSlash(in)

% manage input
if isStringScalar(in)
    in=car(in);
else
    assert(ischar(in),'ERROR: invalid input');
end

%
out=strrep(in,'/',filesep());
out=strrep(out,'\',filesep());

end