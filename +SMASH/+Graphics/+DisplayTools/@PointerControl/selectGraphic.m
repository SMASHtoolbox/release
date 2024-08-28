% selectGraphic Move pointer to graphic object
%
% This method moves the pointer a specified graphic object.
%    selectGraphic(object,target);
% The input "target" must be a handle to an axes, uipanel, uicontrol,
% uitable, or figure object.  The location and size of the target object
% (in pixels) can be requested as output arguments.
%    [location,width]=selectGraphic(...);
% The outputs "location" and "width" are two-element arrays, [x y] and
% [Lx Ly], in pixel units.
% 
% By default, the pointer is moved to the center of the target object.
% Alternation points on the object can be requested by name or relative
% position. 
%    selectGraphic(object,target,reference);
%    selectGraphic(object,target,[xnorm ynorm]);
% Acceptable reference values include 'center', 'north', 'northeast',
% 'east', 'southeast', 'south', 'southwest', 'west', and 'northeast'.
% Relative positions are defined with respect to the southwest corner, e.g.
% the center is [0.5 0.5].
%
% Additional pixel offsets from the reference position can also be
% specified.
%    selectGraphic(object,target,reference,offset);
% The input "offset" can be a scalar or two-element array.  Positive values
% indicate motion *toward* the graphic center.
%
% See also PointerControl, click
%

%
% created January 17, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=selectGraphic(object,target,reference,offset)

% manage input
assert(nargin > 1,'ERROR: no graphic specified');
assert(isscalar(target),'ERROR: cannot locate multiple graphics');
assert(ishandle(target),'ERROR: invalid graphic handle');

switch lower(target.Type)
    case {'axes' 'uipanel' 'uicontrol' 'uitable' 'figure'}
        % keep going
    otherwise
        error('ERROR: cannot select %s objects',target.Type);
end

if (nargin < 3) || isempty(reference)
    reference=[0.5 0.5];
elseif ischar(reference)
    switch lower(reference)
        case 'center'
            reference=[0.5 0.5];
        case 'north'
            reference=[0.5 1];
        case 'northeast'
            reference=[1 1];
        case 'east'
            reference=[1 0.5];
        case 'southeast'
            reference=[1 0];
        case 'south'
            reference=[0.5 0];
        case 'southwest'
            reference=[0 0];
        case 'west'
            reference=[0 0.5];
        case 'northwest'
            reference=[0 1];
        otherwise
            error('ERROR: invalid reference location');
    end
else
    assert(isnumeric(reference) && (numel(reference) == 2),...
        'ERROR: invalid reference location');
    reference=reshape(reference,[1 2]);
end

if (nargin < 4) || isempty(offset)
    offset=[0 0];
else
    assert(isnumeric(offset),'ERROR: invalid offset');
    if isscalar(offset)
        offset=repmat(offset,[1 2]);
    else
        assert(numel(offset) == 2,'ERROR: invalid offset');
    end  
end

% calculate absolute position
TargetPosition=getpixelposition(target,true); % recursive location
width=TargetPosition(3:4);
location=TargetPosition(1:2)+reference.*width;

direction=sign(0.5-reference);
direction(direction == 0)=1;
location=location+direction.*offset;

if ~strcmpi(target.Type,'figure')
    fig=ancestor(target,'figure');
    FigurePosition=getpixelposition(fig);
    location=round(location+FigurePosition(1:2));
end

% store current position and move cursor
object.History(end+1,:)=object.Location;

location(2)=object.MonitorPosition(1,4)-location(2);
location=round(location);
object.Robot.mouseMove(location(1),location(2));

% manage output
if nargout > 0
    varargout{1}=location;
    varargout{2}=round(width);
end

end