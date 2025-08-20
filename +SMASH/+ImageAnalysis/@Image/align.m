% ALIGN Align Image objects
%
% This method aligns an Image object using a set of specified set of (x,y).
% points.  The best fit polynomial through these points becomes a fixed grid 
% path.  
%
% Usage:
%   >> object=align(object,direction,xypath,order);
%    - direction...
%    -xypath should be table of [x y] values 
%    -order is the polynomial order used to define the alignment boundary
%    (default is 1).
% Users will be prompted to select the xypath if input table is omitted.
%
% See also Image, shift
%

%
% created January 1,4 2014 by Daniel Dolan (Sandia National Laboratories)
%    -The Streak class created by Tom Ao was folded into this method
% 
function [object,xypath]=align(object,direction,xypath,order)

% handle input
if (nargin<2) || isempty(direction)
    direction='grid1';
elseif strcmpi(direction,'grid1') || strcmpi(direction,'grid2')
    direction=lower(direction);
else
    error('ERROR: invalid direction');
end

if (nargin<3) || isempty(xypath) % display image so user can select (x,y) points
    xypath=SelectPoints(direction,object);
end
x=xypath(:,1);
y=xypath(:,2);

if (nargin<4) || isempty(order)
    order=1;
end

switch lower(direction)
    case 'grid1'
        param=polyfit(y,x,order);
        xmid=(max(x)+min(x))/2;
        for k=1:numel(object.Grid2)
            xk=polyval(param,object.Grid2(k));
            shift=xk-xmid;
            object.Data(k,:)=...
                interp1(object.Grid1-shift,object.Data(k,:),object.Grid1,...
                'linear',0);
        end
    case 'grid2'
        param=polyfit(x,y,order);
        ymid=(max(y)+min(y))/2;
        for k=1:numel(object.Grid1)
            yk=polyval(param,object.Grid1(k));
            shift=yk-ymid;
            object.Data(:,k)=...
                interp1(object.Grid2-shift,object.Data(:,k),object.Grid2,...
                'linear',0);
        end
end

object=updateHistory(object);

end

function xypath=SelectPoints(direction,object)
x = [];
y = [];
% have user zoom into alignment path
h=view(object,'show');
title(h.axes,'Zoom into the alignment feature');
hzoom=zoom(h.figure);
set(hzoom,'Enable','on');
switch direction
    case 'grid1'
        set(hzoom,'Motion','horizontal');
    case 'grid2'
        set(hzoom,'Motion','vertical');
end
hc=uicontrol('Parent',h.panel,'Style','pushbutton','String',' Next ',...
    'Callback','delete(gcbo)');
waitfor(hc);
set(hzoom,'Enable','off');

% select alignment points
set(h.image,'ButtonDownFcn',@CreatePoint)
hc=uicontextmenu;
uimenu(hc,'Label','Remove point','Callback',@RemovePoint);
hl=line('Parent',h.axes,'UIContextMenu',hc,...
    'XData',[],'YData',[]);
apply(object.GraphicOptions,hl);
set(hl,'LineStyle','none');
title('Select alignment points');
    function CreatePoint(varargin)
        x=get(hl,'XData');
        y=get(hl,'YData');
        current=get(h.axes,'CurrentPoint');
        x(end+1)=current(1,1);
        y(end+1)=current(1,2);
        set(hl,'XData',x,'YData',y);
    end
    function RemovePoint(varargin)
        x=get(hl,'XData');
        y=get(hl,'YData');
        current=get(h.axes,'CurrentPoint');
        x0=current(1,1);
        y0=current(1,2);
        d2=(x-x0).^2+(y-y0).^2;
        [~,index]=min(d2);
        x(index)=[];
        y(index)=[];
        set(hl,'XData',x,'YData',y);
    end

hc=uicontrol('Style','pushbutton','String',' Done ',...
    'Callback','delete(gcbo)');
waitfor(hc);

xypath=[x(:) y(:)];
delete(h.figure);

end