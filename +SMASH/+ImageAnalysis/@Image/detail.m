% DETAIL Interactive detail viewing tool for Image objects
%
% Usage:
%   >> detail(object,target); % interactively select detail region
%
% See also IMAGE, explore, show, slice, view

% created May 28, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=detail(object,target,orientation)

% handle input
if (nargin<2) || isempty(target) || isnan(target)
    target=[];
end

if (nargin<3) || isempty(orientation)
    orientation='landscape';
end
switch lower(orientation)
    case 'portrait'
        axespos{1}=[0.0 0.5 1.0 0.5];
        axespos{2}=[0.0 0.0 1.0 0.5];        
    case 'landscape'
        axespos{1}=[0.0 0.0 0.5 1.0];
        axespos{2}=[0.5 0.0 0.5 1.0];
    otherwise
        error('ERROR: invalid orientation');
end

% create graphical interface
h=basic_figure(target,orientation);

h.uimenu=uimenu(h.figure,'Label','Help');
uimenu(h.uimenu,'Label','About detail view','Callback',@DetailHelp);

% % tweak the figure menu
%  hb=findall(h.figure,'Type','uitoolbar');
%  hb=findall(hb);
%  hb=hb(2:end);
%  drop=true(size(hb));
% for n=1:numel(hb)
%      tag=lower(get(hb(n),'Tag'));
%      if strfind(tag,'cursor')
%          drop(n)=false;
%      elseif strfind(tag,'save')
%          drop(n)=false;
%      end
% end
% set(hb(drop),'Visible','off');
% set(hb,'Separator','off');


% create overview plot
h.axes(1)=axes('Parent',h.panel,'OuterPosition',axespos{1},...
    'Tag','OverviewAxes','YDir',object.GraphicOptions.YDir); %,'XTickLabel','','YTickLabel','');
temp=show(object,h.axes(1));
h.image(1)=temp.image;

xb=xlim(h.axes(1));
x0=mean(xb);
Lx=(xb(2)-xb(1))/4;
x0=x0-Lx/2;
yb=ylim(h.axes(1));
y0=mean(yb);
Ly=(yb(2)-yb(1))/4;
y0=y0-Ly/2;
ROI=rectangle2('Parent',h.axes(1),'Position',[x0 y0 Lx Ly],...
    'LineWidth',2,'LineStyle',':');

% create detail plot
h.axes(2)=axes('Parent',h.panel,'OuterPosition',axespos{2},...
    'Tag','DetailAxes','YDir',object.GraphicOptions.YDir);
temp=show(object,h.axes(2));
daspect(h.axes(2),'auto');
pbaspect(h.axes(2),'auto');
h.image(2)=temp.image;

xlabel(h.axes(2),'');
ylabel(h.axes(2),'');
title(h.axes(2),'');
text('Parent',h.axes(2),'Units','normalized','Position',[1 1],...
    'HorizontalAlignment','right','VerticalAlignment','bottom',...
    'FontWeight','bold','String','Detail region')

hlink=linkprop(h.axes,'CLim');
setappdata(h.axes(1),'CLimLink',hlink);

% final details
hc=findobj(gcf,'Tag','Colorbar');
delete(hc(1));
set(h.axes,'YDir',object.GraphicOptions.YDir);

%% callbacks
set(h.figure,'WindowButtonMotionFcn',@MotionFcn);
    function MotionFcn(varargin)
        current=get(h.axes(2),'CurrentPoint');
        x0=current(1,1);
        y0=current(1,2);
        xb=xlim(h.axes(2));
        yb=ylim(h.axes(2));
        if (x0>=xb(1)) && (x0<=xb(2)) && (y0>=yb(1)) && (y0<=yb(2))
            set(h.figure,'Pointer','crosshair');
        else
            set(h.figure,'Pointer','arrow');
        end
    end

set(h.figure,'WindowKeyPressFcn',@KeyPressCallback);
    function KeyPressCallback(~,eventdata)
        if strcmpi(eventdata.Key,'shift')
            return
        end
        if isempty(eventdata.Modifier)
            moveROI(ROI,h.axes,eventdata.Key);
        elseif strcmpi(eventdata.Modifier,'shift')
            resizeROI(ROI,h.axes,eventdata.Key);
        end
        rectangle2axes(ROI,h.axes);
    end

set(h.image(1),'ButtonDownFcn',@PlaceRectangle)
set(ROI,'ButtonDownFcn',@PlaceRectangle)
    function PlaceRectangle(varargin)
        current=get(h.axes(1),'CurrentPoint');
        current=current(1,1:2);
        position=get(ROI,'Position');
        xb=xlim(h.axes(1));
        if current(1)<(xb(1)+position(3)/2)
            current(1)=xb(1)+position(3)/2;
        elseif current(1)>(xb(2)-position(3)/2)
            current(1)=xb(2)-position(3)/2;
        end
        yb=ylim(h.axes(1));
        if current(2)<(yb(1)+position(4)/2)
            current(2)=yb(1)+position(4)/2;
        elseif current(2)>(yb(2)-position(4)/2)
            current(2)=yb(2)-position(4)/2;
        end
        position(1)=current(1,1)-position(3)/2;
        position(2)=current(1,2)-position(4)/2;
        set(ROI,'Position',position);
        rectangle2axes(ROI,h.axes);
    end

% display completed figure and generate output
rectangle2axes(ROI,h.axes);
figure(h.figure);

if nargout>=1
    varargout{1}=h;
end

end

%% support functions
%%
function rectangle2axes(ROI,haxes)
position=get(ROI,'Position');
xb=position(1)+[0 position(3)];
yb=position(2)+[0 position(4)];
xlim(haxes(2),xb);
ylim(haxes(2),yb);
end

%%
function moveROI(ROI,haxes,key)

xb=xlim(haxes(1));
dx=(xb(2)-xb(1))/100;
yb=ylim(haxes(1));
dy=(yb(2)-yb(1))/100;
mode=get(haxes,'YDir');
if strcmpi(mode,'reverse')
    dy=-dy;
end

position=get(ROI,'Position');
switch lower(key)
    case 'leftarrow'
        position(1)=position(1)-dx;
    case 'rightarrow'
        position(1)=position(1)+dx;
    case 'downarrow'
        position(2)=position(2)-dy;
    case 'uparrow'
        position(2)=position(2)+dy;
end

if position(1)<xb(1)
    position(1)=xb(1);
end
if (position(1)+position(3))>xb(2)
    position(1)=xb(2)-position(3);
end
if position(2)<yb(1)
    position(2)=yb(1);
end
if (position(2)+position(4))>yb(2)
    position(2)=yb(2)-position(4);
end

set(ROI,'Position',position);

end

%%
function resizeROI(ROI,haxes,key)

xb=xlim(haxes(1));
dx=(xb(2)-xb(1))/100;
yb=ylim(haxes(1));
dy=(yb(2)-yb(1))/100;

position=get(ROI,'Position');
switch lower(key)
    case 'leftarrow'
        position(1)=position(1)+dx/2;
        position(3)=position(3)-dx;
    case 'rightarrow'
        position(1)=position(1)-dx/2;
        position(3)=position(3)+dx;
    case 'downarrow'
        position(2)=position(2)+dy/2;
        position(4)=position(4)-dy;
    case 'uparrow'
        position(2)=position(2)-dy/2;
        position(4)=position(4)+dy;
end

Lx=xb(2)-xb(1);
if position(3)<dx
    position(3)=dx;
    position(1)=position(1)-dx/2;
elseif position(3)>Lx
    position(3)=Lx;
end
Ly=yb(2)-yb(1);
if position(4)<dy
    position(4)=dy;
    position(2)=position(2)-dy/2;
elseif position(4)>Ly
    position(4)=Ly;
end

set(ROI,'Position',position);
moveROI(ROI,haxes,'');

end


%%
function DetailHelp(varargin)

h=findall(0,'Tag','DetailHelpWindow');
if ishandle(h)
    figure(h);
    return
end

message={};
message{end+1}='This is a tool for viewing local details within the context of the full image.';
message{end+1}='The left plot shows the entire image, while the right plot is a detailed view of that image.';
message{end+1}='The location and size of the the detail view is displayed as a rectangle on the full image.';
message{end+1}='Use the array keys or click the upper image to move the detail region.';
message{end+1}='Hold down the shift button and an arrow key to change the size of the detail region.';

message=sprintf('%s ',message{:});
h=msgbox(message,'About detail view');
set(h,'Tag','DetailHelpWindow');

end