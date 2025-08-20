function clickItem(object,target)

persistent robot button1
if isempty(robot)
    robot=java.awt.Robot();
    %button1=java.awt.event.InputEvent.BUTTON1_MASK; 
    button1=java.awt.event.InputEvent.BUTTON1_DOWN_MASK;
end

persistent info
if isempty(info)
    info=java.awt.MouseInfo.getPointerInfo;
end

% click location
x=target.getLocationOnScreen().getX()+target.getSize().getWidth()/2;
y=target.getLocationOnScreen().getY()+target.getSize().getHeight()/2;

object.Master.show();
pause(0.2)
robot.mouseMove(x,y);
robot.mousePress(button1);
robot.mouseRelease(button1);

end