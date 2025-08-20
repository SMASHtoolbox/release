% checkGraphic Query MATLAB graphics system
%
% This function checks the graphics system used by MATLAB.
%    value=checkGraphics();
% Output "value" indicates whether 'Java' or 'Javascript' graphics are in
% use.  Omitting the output:
%    checkGraphics();
% prints a message in the command window indicating the graphic system.
%
% NOTE: the returned value denotes the *primary* graphic
% system being used.  JavaScript graphics have been available since MATLAB
% release 2015b, but Java was still used for standard figures.  Java
% graphics were removed in the new desktop beta and formally replaced in
% release 2025a.  This function allows developers to detect whether legacy
% code based on Java graphics can be used or if JavaScript alternatives are
% required.  In summary, this function returns:
%    -'Java' for all releases through R2023a.
%    -'JavaScript' for all release R2025a and later.
%    -'JavaScript' for releases R2023b, R2024a, and R2024b using the new
%    desktop beta and 'Java' otherwise.
%
% See also SMASH.Graphics
%
function varargout=checkGraphics()

% graphics query is slow, so keep result through current session
mlock();
persistent value
if isempty(value)
    value='Java'; % default to legacy value
    try %#ok<TRYNC>
        info=rendererinfo();
        if strcmpi(info.GraphicsRenderer,'WebGL')
            value='JavaScript';
        end
    end
end

% manage output
if nargout() > 0
    varargout{1}=value;
    return
end
fprintf('MATLAB is using %s graphics\n',value);

end