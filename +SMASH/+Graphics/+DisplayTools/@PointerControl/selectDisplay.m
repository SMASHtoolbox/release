% selectDisplay Move pointer to specified display
%
% This method moves the point to the center of a display.
%    selectDisplay(object,monitor);
% The input "monitor" is an integer indicating the selected display.  The
% primary display is used when this input is omitted.eater than one.
%
% See also PointerControl, selectGraphic
%

%
% created January 17, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function selectDisplay(object,index)

% manage input
if (nargin < 2) || isempty(index)
    index=1;
else
    assert(isnumeric(index) && isscalar(index),'ERROR: invalid display');
    valid=1:size(object.MonitorPosition,1);
    assert(any(index == valid),'ERROR: invalid display for this system');   
end

% move pointer
position=object.MonitorPosition(index,:);
location(1)=position(1)+position(3)/2;
location(2)=position(2)+position(4)/2;
object.Location=round(location);

end