% open Open file in local OS
% 
% This function opens a requested file in the local operating system.
%    open(file);
% The input "file" is opened with the appropriate local program, in the
% same manner as double clicking the icon.  When "file" is a folder, that
% location is opened in the local system browser.  If no file is specified:
%    open();
% the current folder is opened outside of MATLAB.
%
% For Windows systems, this function is equivalent to MATLAB's winopen
% command.  Similar behavior is invoked on Mac and Linux systems.
%
% See also SMASH.System, winopen
%
function open(file)

% manage input
if (nargin < 1) || isempty(file)
    file=pwd;
else
    if isStringScalar(file)
        file=char(file);
    else
        assert(ischar(file),'ERROR: invalid file');
    end
end

if ispc
    winopen(file);
    return
end

if ismac
    command=sprintf('open "%s"',file);
else
    command=sprintf('xdg-open "%s"',file);
end
system(command);

end