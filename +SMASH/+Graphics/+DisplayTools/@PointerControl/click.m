% click Simulate mouse click
%
% This method simulates a mouse click at the pointer's current location.
%    click(object);
% Passing a graphic handle:
%    click(object,target);
% ensures that the parent figure is visible during the click.
%
% See also PointerControl, selectGraphic
%

%
% created January 17, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function click(object,target)

% manage input
if nargout > 1
    try
        target=ancestor(target,'figure');
        figure(target);
        drawnow();
    catch
        error('ERROR: invalid target object')
    end
end

location=object.Location;
location(2)=object.MonitorPosition(1,4)-location(2);
location=round(location);
object.Robot.mouseMove(location(1),location(2));

object.Robot.mousePress(object.Button1);
object.Robot.mouseRelease(object.Button1);

end