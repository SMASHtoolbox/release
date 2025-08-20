function [p, f, newPos4] = determineScaling(varargin)

newPos4 = 1;
p = 1;
f = 1;
if ismac
    % p = 72/96; % this didn't work
    % According to Dan: there isn't much you can do about this because the
    % Mac scaling parameter in MATLAB is fundamentally incorrect and varies
    % with monitor. Dan has been pushing MATLAB to try and fix it.
    p = 1;
elseif isunix
    f = 0.85;
end

if nargin > 0
    GUIHeight = varargin{1};
    set(0, 'units', 'pixels');
    pix = get(0, 'screensize');
    if nargin > 1
        heightConstraint = varargin{2};
        newPos4 = heightConstraint;
    else
        heightConstraint = 1;
    end
    if pix(4)*heightConstraint < GUIHeight
        rat = heightConstraint*pix(4)/GUIHeight;
        p = p*rat;
        f = f*rat;
        newPos4 = 1;
    end
end
    
end