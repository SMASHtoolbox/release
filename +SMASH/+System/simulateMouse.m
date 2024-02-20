% simulateMouse Simulate mouse action
%
% This function simulates a mouse action.
%    simulateMouse('press'); % simulate primary button click
%    simulateMouse('release'); % simulate primary button release
%
% See also SMASH.System
%

%
% created April 8, 2018 by Daniel Dolan (Sandia National Laboratories)  
%
function simulateMouse(action)

% manage input
assert(nargin > 0,'ERROR: insufficient input')
assert(ischar(action),'ERROR: invalid mouse action');

% reusable objects
persistent robot button1 button2 button3
if isempty(robot)
    robot=java.awt.Robot();
    button1=java.awt.event.InputEvent.BUTTON1_MASK; 
    button2=java.awt.event.InputEvent.BUTTON2_MASK; 
    button3=java.awt.event.InputEvent.BUTTON3_MASK; 
end

number=1;
switch number
    case 1
        button=button1;
    case 2
        button=button2;
    case 3
        button=button3;
end

% simulate action
switch lower(action)
    case 'press'
        robot.mousePress(button);
        robot.mouseRelease(button);
    case 'release'
        robot.mouseRelease(button);
    otherwise
        error('ERROR: invalid mouse actoin');
end

end