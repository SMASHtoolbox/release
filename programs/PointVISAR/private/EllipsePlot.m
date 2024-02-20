% EllipsePlot : add an ellipse to an axes
% created 1/3/2005 by Daniel Dolan
% store and overwrite modes
%
function varargout = EllipsePlot(params, mode, AxesHandle, numpoints)

% input check
if nargin < 1
    params = [];
end
if nargin < 2
    mode = '';
end
if nargin < 3
    AxesHandle = [];
end
if nargin < 4
    numpoints = [];
end

% default values
if isempty(params)
    params = [0 0 1 1 0];
end
if isempty(mode)
    mode = 'overwrite';
end
if isempty(AxesHandle)
    AxesHandle = gca;
end
if isempty(numpoints)
    numpoints = 200;
end

% extract ellipse parameters
x0 = params(1);
y0 = params(2);
Ax = params(3);
Ay = params(4);
epsilon = params(5);

theta = linspace(0, 2 * pi, numpoints);

x = x0 + Ax * cos(theta);
y = y0 + Ay * sin(theta - epsilon);

axes(AxesHandle);
LineHandle = line(x, y, 'Color', [0 0 0],'LineWidth',2);

switch mode
    case 'overwrite'
        hl = findobj(AxesHandle, 'Tag', 'EllipsePlot');
        delete(hl);   
    case 'store'
        % do nothing
    otherwise
        error('Unknown mode');
end

set(LineHandle, 'Tag', 'EllipsePlot', 'UserData', params);

if nargout > 0
    varargout{1} = LineHandle;
end