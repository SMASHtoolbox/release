
function AdjustRectangle(src,~,object)

% determine how and where click occurred
haxes=ancestor(src,'axes');
fig=ancestor(haxes,'figure');

selection=get(fig,'SelectionType');
if ~strcmpi(selection,'normal')
    return
end
start=get(haxes,'CurrentPoint');

% determine adjustment mode
pos=get(src,'Position');
x1=pos(1);
Lx=pos(3);
x2=x1+Lx;
y1=pos(2);
Ly=pos(4);
y2=y1+Ly;

Lxfrac=Lx/20;
Lyfrac=Ly/20;

x=[x1 x2 x2 x1];
y=[y1 y1 y2 y2];

xc=start(1,1);
yc=start(1,2);
L2=(x-xc).^2+(y-yc).^2;
[~,index]=min(L2);
switch index
    case 1
        mode='corner1';
        if abs(x(index)-xc) >= Lxfrac
            mode='edge1';
        elseif abs(y(index)-yc) >= Lyfrac                    
            mode='edge4';
        end
    case 2
        mode='corner2';
        if abs(x(index)-xc) >= Lxfrac
            mode='edge1';
        elseif abs(y(index)-yc) >= Lyfrac
            mode='edge2';
        end
    case 3
        mode='corner3';
        if abs(x(index)-xc) >= Lxfrac
            mode='edge3';
        elseif abs(y(index)-yc) >= Lyfrac
            mode='edge2';
        end
    case 4
        mode='corner4';
        if abs(x(index)-xc) >= Lxfrac
            mode='edge3';
        elseif abs(y(index)-yc) >= Lyfrac
            mode='edge4';
        end
end

previous.MotionFcn=get(fig,'WindowButtonMotionFcn');
previous.ButtonUp=get(fig,'WindowButtonUpFcn');
set(fig,'WindowButtonMotionFcn',@trackMotion,...
    'WindowButtonUpFcn',@resetCallbacks)
    function trackMotion(varargin)       
        new=get(haxes,'CurrentPoint');
        dx=new(1,1)-start(1,1);
        dy=new(1,2)-start(1,2);
        switch mode           
            case 'corner1'
                x1=pos(1)+dx;
                y1=pos(2)+dy;
                Lx=pos(3)-dx;
                Ly=pos(4)-dy;
            case 'corner2'           
                y1=pos(2)+dy;
                Lx=pos(3)+dx;
                Ly=pos(4)-dy;                
            case 'corner3'                
                Lx=pos(3)+dx;
                Ly=pos(4)+dy;
            case 'corner4'
                x1=pos(1)+dx;                
                Lx=pos(3)-dx;
                Ly=pos(4)+dy;
            case 'edge1'
                y1=pos(2)+dy;
                Ly=pos(4)-dy;
            case 'edge2'
                Lx=pos(3)+dx;
            case 'edge3'
                Ly=pos(4)+dy;
            case 'edge4'
                x1=pos(1)+dx;
                Lx=pos(3)-dx;
        end        
        if (Lx>0) && (Ly>0)
            set(src,'Position',[x1 y1 Lx Ly]);
        end
    end
    function resetCallbacks(varargin)
        set(fig,'WindowButtonMotionFcn',previous.MotionFcn,...
            'WindowButtonUpFcn',previous.ButtonUp)
        pos=get(src,'Position');
        object.XBound=[pos(1) pos(1)+pos(3)];
        object.YBound=[pos(2) pos(2)+pos(4)];
        update(object);
    end

end
