% frame Visually group controls with a frame
%
% This method creates a frame uicontrol inside a Dialog box, visually
% grouping a set of existing controls (created with the addblock method).
% The target controls are specified as an array of graphic handles.
%    >> h=frame(object,target);
%
% See also Dialog, addblock

% 
% created June 2, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=frame(object,target)

% handle input
assert(nargin>=2,'ERROR: insufficient input');
N=numel(target);
valid=false;
for n=1:N
    if ishandle(target(n))
        valid=true;
    else
        valid=false;
        break
    end
end
assert(valid,'ERROR: invalid target handle(s)');

% determine frame boundaries
position=get(target(1),'Position');
left=position(1);
right=left+position(3);
bottom=position(2);
top=bottom+position(4);
for n=2:N
    temp=get(target(n),'Position');
    left=min(left,temp(1));
    bottom=min(bottom,temp(2));
    right=max(right,temp(1)+temp(3));
    top=max(top,temp(2)+temp(4));    
end

left=left-object.HorizontalMargin/2;
right=right+object.HorizontalMargin/2;
bottom=bottom-object.VerticalMargin/2;
top=top+object.VerticalMargin/2;
position=[left bottom right-left top-bottom];

% create frame box and move handle to the end for visibility
h=uicontrol('Parent',object.Handle,'Style','frame',...
    'Units','pixels','Position',position);
children=get(object.Handle,'Children');
set(object.Handle,'Children',children([2:end 1]));

% handle output
if nargout>0
    varargout{1}=h;
end

end