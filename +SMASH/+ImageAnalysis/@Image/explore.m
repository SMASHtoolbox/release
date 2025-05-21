% EXPLORE Interactive slice exploring tool for Image objects
%
% Usage:
%   >> explore(object); % interactively explore slices
%
% See also IMAGE, detail, profile, show, slice, view

% created November 14, 2012 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=explore(object)

% create graphical interface
%h=basic_figure(target,'full');

% create axes
x0=0.15;
y0=0.15;
Lx=1-2*x0;
Ly=1-2*y0;

Lx1=0.75*Lx;
Lx2=Lx-Lx1;
Ly1=0.75*Ly;
Ly2=Ly-Ly1;

%fig=figure;
SMASH.MUI.Figure();
fig=gcf;

haxes(1)=axes('Parent',fig,'Units','normalized','Position',[x0 y0+Ly2 Lx1 Ly1],...
    'Tag','ImageAxes','XTickLabel','','YTickLabel','','Box','on',...
    'YDir',object.GraphicOptions.YDir);
temp=show(object,haxes(1));
xlims = xlim(haxes(1));
himage=temp.image;
colormap(fig,object.GraphicOptions.ColorMap);
caxis(haxes(1),object.DataLim);
axis(haxes(1),'tight');
hcrosshair=line('Parent',haxes(1),...
    'Color',object.GraphicOptions.LineColor,...
    'UserData',[],'Tag','crosshair');
title(haxes(1),object.GraphicOptions.Title);

hc=findobj(gcf,'Tag','Colorbar');
delete(hc);

haxes(2)=axes('Parent',fig,'Units','normalized','Position',[x0+Lx1 y0+Ly2 Lx2 Ly1],...
    'Tag','VerticalSliceAxes','Box','on',...
    'XAxisLocation','top','YAxisLocation','right',...
    'YDir',object.GraphicOptions.YDir);
xlabel(haxes(2),object.DataLabel);
ylabel(haxes(2),object.Grid2Label);
hliney=line('Parent',haxes(2),'Color','k','Tag','VerticalSliceLine');

haxes(3)=axes('Parent',fig,'Units','normalized','Position',[x0 y0 Lx1 Ly2],...
    'Tag','HorizontalSliceAxes','Box','on');
xlabel(haxes(3),object.Grid1Label);
ylabel(haxes(3),object.DataLabel);
hlinex=line('Parent',haxes(3),'Color','k','Tag','HorizontalSliceLine');

haxes(4)=axes('Parent',fig,'Units','normalized','Position',[x0+Lx1 y0 Lx2 Ly2],...
    'Tag','InformationAxes');
axis(haxes(4),'off');
hlabel=text('Parent',haxes(4),'Units','data','Position',[1 0],...
    'HorizontalAlignment','right','VerticalAlignment','bottom',...
    'Tag','InformationText');

hlink=linkprop(haxes([1 2]),'YLim');
setappdata(haxes(2),'hlink',hlink);
hlink=linkprop(haxes([1 3]),'XLim');
setappdata(haxes(3),'hlink',hlink);

xlim(haxes(1),xlims); % simple fix to problem caused by hcrosshair generation

% local functions and callbacks
UpdateLines;
    function UpdateLines(varargin)
        % cross hair
        data=get(hcrosshair,'UserData');
        if isempty(data)
             x=mean(xlim(haxes(1)));
             y=mean(ylim(haxes(1)));
        else
            x=data(1);
            y=data(2);
        end
        x=interp1(object.Grid1,object.Grid1,x,'nearest');       
        y=interp1(object.Grid2,object.Grid2,y,'nearest');
          x1=min(object.Grid1);
          x2=max(object.Grid1);
          y1=min(object.Grid2);
          y2=max(object.Grid2);
        xc=[x1 x2 nan  x  x];
        yc=[y   y nan y1 y2];
        set(hcrosshair,'XData',xc,'YData',yc,'UserData',[x y]);        
        % vertical slice
        temp=slice(object,'Grid1',x);
        set(hliney,'XData',temp.Data,'YData',temp.Grid);
        % horizontal slice      
        temp=slice(object,'Grid2',y);
        set(hlinex,'XData',temp.Grid,'YData',temp.Data); 
        % status window
        label={};
        label{end+1}=sprintf('%s : %g',object.Grid1Label,x);
        label{end+1}=sprintf('%s : %g',object.Grid2Label,y);
        z=lookup(object,x,y);
        label{end+1}=sprintf('%s : %g',object.DataLabel,z);
        set(hlabel,'String',label);
    end

set(himage,'ButtonDownFcn',@MoveCrosshair);
set(hcrosshair,'ButtonDownFcn',@MoveCrosshair);
    function MoveCrosshair(varargin)
        position=get(haxes(1),'CurrentPoint');
        x=position(1,1);       
        y=position(1,2);
        set(hcrosshair,'UserData',[x y]);
        UpdateLines;
    end

set(fig,'WindowKeyPressFcn',@StepCrosshair)
    function StepCrosshair(~,eventdata)
        key=eventdata.Key;
        data=get(hcrosshair,'UserData');        
        x=data(1);
        m=find(object.Grid1>=x,1,'first');      
        if strcmp(key,'leftarrow') && (m>1)
            m=m-1;
        elseif strcmp(key,'rightarrow') && (m<numel(object.Grid1))
            m=m+1;
        end
        x=object.Grid1(m);        
        y=data(2);
        n=find(object.Grid2>=y,1,'first');
        if strcmp(key,'downarrow') && (n>1)
            n=n-1;            
            %n=n+1; % backwards to match image orientation
        elseif strcmp(key,'uparrow') && (n<numel(object.Grid2))
            n=n+1;
            %n=n-1; % backwards to match image orientation
        end
        y=object.Grid2(n);
        set(hcrosshair,'UserData',[x y]);
        UpdateLines;
    end

figure(fig);

% handle output
if nargout>=1
    varargout{1}=haxes;
end

end