% REGION Select a region of interest inside a Image object
%
% Standard use:
%   >> data=region(object);
% This command displays the object and allows a region of interest
% to be selected interactively.  To specify boundary points of the region,
% click the left mouse button on the displayed image.  Shift-clicking on
% the image closes the region and stops point addition.
%
% To move a closed region, click and drag anywhere on the boundary.  To
% move an individual boundary point, shift-click and drag.  Right-clicking
% a closed region reveals a menu for inserting new points, deleting the
% nearest point, and deleting all points.  Modifications can be made until
% the user presses the "Done" button at the bottom of the figure, at which
% point information about the region boundary and its contents are returned
% as a structure.
% 
% Advanced use:
%  >> [hbf,probe]=region(object,'custom'); 
% This command is for advanced users only.  The same figure is generated as
% above, but program execution is not blocked and no "Done" button is
% created.  Instead, a handle structure (hbf) and function handle (probe)
% is returned for custom applications.  The hbf structure contains
% fields for the figure, axes, and uipanel handles.  The function handle
% can be evaluated to "probe" points inside the region.
%    >> data=feval(probe);
%
% See also IMAGE, crop

% created October 15, 2012 by Daniel Dolan (Sandia National Laboratories)
% revised November 7, 2012 by Daniel Dolan
%   -Move entire boundary by mouse click
%   -Move boundary point by shift-click
% modified October 17, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=region(object,mode,label)
%% handle input
if (nargin<2) || isempty(mode)
    mode='standard';
end

if (nargin<3) || isempty(label)
    label='Use mouse to select region of interest';
end
assert(ischar(label) || iscellstr(label),'ERROR: invalid label')

%% prompt user
%hbf=basic_figure('Name','Select region of interest');
%h=basic_figure;
%himage=image(object,h.axes);
h=view(object,'show');
title(label)

boundary=line('Parent',h.axes,'XData',[],'YData',[]);
set(boundary,'Color',object.GraphicOptions.LineColor,...
    'LineStyle','--','Marker','o');
setappdata(boundary,'NearestPoint',1);

%%
set(h.image,'ButtonDownFcn',@AddPoint)
    function AddPoint(~,~)        
        x=get(boundary,'XData');
        y=get(boundary,'YData');
        switch lower(get(h.figure,'SelectionType'))
            case 'normal'
                current=get(h.axes,'CurrentPoint');
                xnew=current(1,1);
                ynew=current(1,2);
            otherwise
                xnew=x(1);
                ynew=y(1);
                set(h.image,'ButtonDownFcn','');
        end
        x(end+1)=xnew;
        y(end+1)=ynew;
        set(boundary,'XData',x,'YData',y);
        setappdata(boundary,'NearestPoint',numel(x));
    end

%%
set(boundary,'ButtonDownFcn',@SelectPoint)
    function SelectPoint(~,~)
        switch lower(get(h.figure,'SelectionType'))
            case 'normal'
                StartMove;
            case 'extend'
                FindNearestPoint();
                set(h.figure,...
                    'WindowButtonMotionFcn',@MovePoint,...
                    'WindowButtonUpFcn',@DoneMoving);
        end      
    end
    function MovePoint(~,~)
        x=get(boundary,'XData');
        y=get(boundary,'YData');
        index=getappdata(boundary,'NearestPoint');
        current=get(h.axes,'CurrentPoint');
        xnew=current(1,1);
        ynew=current(1,2);
        x(index)=xnew;
        y(index)=ynew;
        if (index==1)
            x(end)=xnew;
            y(end)=ynew;
        end
        set(boundary,'XData',x,'YData',y);
    end
    function DoneMoving(~,~)
        set(h.figure,'WindowButtonMotionFcn','');
    end

%%
hm=uicontextmenu;
%uimenu(hm,'Label','Move all points','Callback',@StartMove);
uimenu(hm,'Label','Insert point','Callback',@InsertPoint);
uimenu(hm,'Label','Remove nearest point','Callback',@RemoveNearest);
uimenu(hm,'Label','Remove all points','Callback',@RemoveAll);
set(boundary,'UIContextMenu',hm);
%%
    function InsertPoint(~,~)    
        % new point location
        pos=get(h.axes,'CurrentPoint');
        x0=pos(1,1);
        y0=pos(1,2);        
        % shortest distance between new point and existing boundary lines
        x=get(boundary,'XData');
        y=get(boundary,'YData');
        Nboundary=numel(x)-1; % last point repeats the first
        distance=zeros(Nboundary,1);
        for k=1:Nboundary
            xd=x(k:k+1);
            yd=y(k:k+1);
            p=[xd(1)-x0 yd(1)-y0 0];
            q=[xd(2)-x0 yd(2)-y0 0];
            base=sqrt(diff(xd)^2+diff(yd)^2);
            distance(k)=norm(cross(p,q))/base;
        end        
        % insert new point on closest boundary
        [~,k]=min(distance);
        x=[x(1:k) x0 x(k+1:end)];
        y=[y(1:k) y0 y(k+1:end)];
        set(boundary,'XData',x,'YData',y);
        
    end
%%
    function StartMove(~,~)
        previous=get(h.axes,'CurrentPoint');
        setappdata(boundary,'previous',previous);
        set(h.figure,...
            'WindowButtonMotionFcn',@MoveRegion,...
            'WindowButtonUpFcn',@StopMove);
    end
    function MoveRegion(~,~)
        current=get(h.axes,'CurrentPoint');
        previous=getappdata(boundary,'previous');
        change=current-previous;
        setappdata(boundary,'previous',current);
        x=get(boundary,'XData');
        y=get(boundary,'YData');
        x=x+change(1,1);
        y=y+change(1,2);
        set(boundary,'XData',x,'YData',y);
    end
    function StopMove(~,~)
        set(h.figure,...
            'WindowButtonMotionFcn','','WindowButtonUpFcn','');
    end
%%
    function RemoveNearest(~,~)
        FindNearestPoint();
        index=getappdata(boundary,'NearestPoint');
        x=get(boundary,'XData');
        y=get(boundary,'YData');
        x(index)=[];
        y(index)=[];
        set(boundary,'XData',x,'YData',y);
    end
%%
    function RemoveAll(~,~)
        set(boundary,'XData',[],'YData',[]);
        set(h.image,'ButtonDownFcn',@AddPoint);
    end

    function distance2=FindNearestPoint()
        x=get(boundary,'XData');
        y=get(boundary,'YData');
        current=get(h.axes,'CurrentPoint');
        xnew=current(1,1);
        ynew=current(1,2);
        distance2=(x-xnew).^2+(y-ynew).^2;
        [~,index]=min(distance2);
        setappdata(boundary,'NearestPoint',index);
    end
%% 
    function data=probe_region(data)
        if (nargin<1) || isempty(data)
            data.xbound=get(boundary,'XData');
            data.ybound=get(boundary,'YData');
        end
        xb=[min(data.xbound) max(data.xbound)];
        yb=[min(data.ybound) max(data.ybound)];
        keepx=(object.Grid1>=xb(1)) & (object.Grid1<=xb(2));
        keepy=(object.Grid2>=yb(1)) & (object.Grid2<=yb(2));
        data.x=object.Grid1(keepx);
        data.y=object.Grid2(keepy);
        ZData=object.Data(keepy,keepx);
        [XData,YData]=meshgrid(data.x,data.y);
        inside=inpolygon(XData,YData,data.xbound,data.ybound);
        ZData(~inside)=nan;
        data.z=ZData;        
    end

%%
if strcmp(mode,'custom') % custom mode
    varargout{1}=hbf;
    varargout{2}=@probe_region;
    return
end

done=uicontrol('Parent',h.panel,...
    'Style','pushbutton','String',' Done ',...
    'UserData',0,'Callback','set(gcbo,''UserData'',1);');
waitfor(done,'UserData');
set(done,'UserData',0);

data=probe_region;

close(h.figure);

if (nargout==0)
    figure;
    imagesc(data.x,data.y,data.z);
end
if (nargout>=1)
    varargout{1}=data;
end

end
