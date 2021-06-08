% addButton Add button to the interface
%
% This method adds a new button to the graphical interface.
%    addButton(object,label); 
% Specifying an output returns the handle of the new button.
%    ha=addButton(...);
%
% Buttons are placed from left to right in the order they are created.
%
% See also BasicGUI, addAxes, refresh
%

%
% created December 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=addButton(object,label)

% manage input
if (nargin<2) || isempty(label)
    label=' button ';
end

assert(ischar(label),'ERROR: invalid button label');

% create button
dummy=repmat('M',size(label));
h=uicontrol('Parent',object.ButtonPanel,...
    'Style','pushbutton','String',dummy);
position=get(h,'Extent');
set(h,'Position',position,'String',label);

object.ButtonObject(end+1)=h;
refresh(object,'button');

% manage output
if nargout>0
    varargout{1}=h;
end

end