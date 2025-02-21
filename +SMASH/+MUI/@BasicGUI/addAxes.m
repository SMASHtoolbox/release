% addAxes Add axes to the interface
%
% This method adds a new axes to the graphical interface.
%    addAxes(object); % competely fill panel
%    addAxes(object,position); % partially fill panel (normalized units)
% Specifying an output returns the handle of the new axes object.
%    ha=addAxes(...);
%
% See also BasicGUI, addButton, refresh
%

%
% created December 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=addAxes(object,position)

% manage input
if (nargin<2) || isempty(position)
    position=[0 0 1 1];
end

assert(isnumeric(position) && all(size(position)==[1 4]),...
    'ERROR: invalid axes position');

% create axes
h=axes('Parent',object.AxesPanel,...
    'Units','normalized','OuterPosition',position);

object.AxesObject(end+1)=h;
refresh(object,'axes');

% manage output
if nargout>0
    varargout{1}=h;
end

end