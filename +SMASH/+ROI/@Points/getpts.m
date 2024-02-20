% getpts Interactively select points
%
% This method interactively selects points using the mouse.
%    [x,y]=getpts(mode);
% Any mode supported by the Points class can be specified.  The default
% mode 'open' is used if none is specified.
%
% Interactive selections are made in the current axes of the current figure
% by default.  A target axes for point selection can also be specified.
%    [x,y]=getpts(target,mode);
%
%  Left-clicking on the target axes selects a new point, while
%  shift-clicking removes the nearest point; the backspace and delete
%  buttons remove the last added point. Right-clicking brings up a settings
%  dialog, where point coordinates can be manually adjusted.
%
% See also Points
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function [x,y,object]=getpts(varargin)

% manage input
target=[];
mode='open';
for n=1:nargin
    if ishandle(varargin{n})
        target=varargin{n};
    elseif ischar(varargin{n})
        mode=lower(varargin{n});
    else
        error('ERROR: invalid input');
    end
end

if isempty(target)
    target=gca;
end
switch lower(get(target,'Type'))
    case 'axes'
        % continue
    case 'figure'
        target=get(target,'CurrentAxes');
    case 'uipanel'
        target=ancestor(target,'figure');
        target=get(target,'CurrentAxes');
    otherwise
        error('ERROR: invalid target axes')
end

switch mode
    case {'open' 'connected' 'closed' 'convex'}
        % valid choices
    otherwise
        error('ERROR: invalid mode');
end

%
persistent ns
if isempty(ns)
    ns=packtools.import('.*');
end
object=ns.Points(mode);

object=select(object,target);
if isempty(object.Data)
    x=[];
    y=[];
else
    x=object.Data(:,1);
    y=object.Data(:,2);
end

end