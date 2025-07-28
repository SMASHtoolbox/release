% checkGraphic Query MATLAB graphics system
%
% This function checks the graphics system being used by MATLAB.
%    value=checkGraphics();
% Output "value" is 'Java' for all MATLAB releases prior to 2023a and
% 'JavaScript' from 2025a onward.  Releases 2023a through 2024b return
% 'JavaScript' when the new desktop beta is running and 'Java' when it is
% not.
%
% Omitting the output:
%    checkGraphics();
% prints a message in the command window indicating the graphic system in
% use.
%
% NOTE: the value returned by this method denotes the *primary* graphic
% system being used.  JavaScript graphics have been available since MATLAB
% release 2015b, but Java was still used for standard figure.  Java
% graphics were removed in the new desktop beta and formally in release
% 2025a.  This function allows developers to detect whether legacy code
% based on Java graphics can be used or if JavaScript alternatives are
% required.
%
% See also SMASH.Graphics
%
function varargout=checkGraphics()

value='Java'; % default to legacy value
try %#ok<TRYNC>
    info=rendererinfo();
    if strcmpi(info.GraphicsRenderer,'WebGL')
        value='JavaScript';
    end
end

% manage output
if nargout() > 0
    varargout{1}=value;
    return
end
fprintf('MATLAB is using %s graphics\n',value);

end