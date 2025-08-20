% CENTER_ELLIPSE Centers a Image object based on a fitted ellipse
%
% See also IMAGE, center

% created April 8, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 17, 2013 by Tommy Ao (Sandia National Laboratories)
%
function [object,params]=center_ellipse(object,varargin)
%%

% manage input
Narg=numel(varargin);
if Narg>=1
    radius=varargin{1};
    if strcmpi(radius,'equal')
        radius=lower(radius);
    elseif isnumeric(radius)
        assert(isnumeric(radius),'ERROR: invalid radius value');
        if isscalar(radius)
            radius=repmat(radius,[1 2]);
        end
        assert(numel(radius)==2,'ERROR: invalid radius value');
        assert(all(radius>0),'ERROR: invalid radius value');
    else
        error('ERROR: invalid radius value');
    end   

else
    radius=[];
end

if Narg>=2
    epsilon=varargin{2};
    assert(isnumeric(epsilon),'ERROR: invalid epsilon value');
    assert(isscalar(epsilon),'ERROR: invalid epsilon value');
else
    epsilon=[];
end

% create graphics
h=view(object,'show');
set(h.figure,'Name','Center Image object')
title(h.axes,'Select ellipse boundary points')

set(h.image,'ButtonDownFcn',@AddPoint);
hline(1)=line('Parent',h.axes,'Tag','SelectedPoints',...
    'XData',[],'YData',[],'Visible','off',...    
    'ButtonDownFcn',@AddPoint);
hline(2)=line('Parent',h.axes,'Tag','Ellipse',...
    'XData',[],'YData',[],'Visible','off',...
    'ButtonDownFcn',@AddPoint);
apply(object.GraphicOptions,hline);
set(hline(1),'LineStyle','none');
set(hline(2),'Marker','none');

hc=uicontextmenu;
uimenu(hc,'Label','Remove nearest point',...
    'Callback',{@RemovePoint,'nearest'});
uimenu(hc,'Label','Remove all points',...
    'Callback',{@RemovePoint,'all'});
set([hline h.image],'UIContextMenu',hc);

hbutton=uicontrol('Parent',h.panel,...
    'Style','pushbutton','String',' Done ',...
    'Callback','delete(gcbo)');

waitfor(hbutton);
[x0,y0,params]=updateGUI;
close(h.figure);

object.Grid1=object.Grid1-x0;
object.Grid2=object.Grid2-y0;

%%
    function AddPoint(src,~)        
        fig=ancestor(src,'figure');
        if strcmpi(get(fig,'SelectionType'),'normal')
            % do nothing
        else
            return
        end        
        haxes=ancestor(src,'axes');
        current=get(haxes,'CurrentPoint');
        xnew=current(1,1);
        ynew=current(1,2);        
        hl=findobj(haxes,'Tag','SelectedPoints');
        x=get(hl,'XData');
        y=get(hl,'YData');
        
        x(end+1)=xnew;
        y(end+1)=ynew;
        set(hl,'XData',x,'YData',y,'Visible','on');
        updateGUI;
    end
%%
    function RemovePoint(~,~,choice)
        switch choice
            case 'nearest'
                x=get(hline(1),'XData');
                y=get(hline(1),'YData');
                current=get(h.axes,'CurrentPoint');
                x0=current(1,1);
                y0=current(1,2);
                d2=(x-x0).^2+(y-y0).^2;
                [~,index]=min(d2);
                x(index)=[];
                y(index)=[];
                set(hline(1),'XData',x,'YData',y);
            case 'all'
                set(hline(1),'XData',[],'YData',[]);
        end
        updateGUI;
        
    end
%%
    function [x0,y0,params]=updateGUI()
        x=get(hline(1),'XData');
        y=get(hline(1),'YData');
        if numel(x)<4
            set(hbutton,'Enable','off');
            set(hline(2),'Visible','off');
            return
        end
        if isempty(radius) && isempty(epsilon)           
            params=DirectEllipseFit(x,y);
        elseif strcmpi(radius,'equal') && (epsilon==0) 
            params=CircleFitByPratt([x(:) y(:)]);
            params(4)=params(3);
            params(5)=0;
        elseif ~isempty(radius) && ~isempty(epsilon)    
            guess=[mean(x) mean(y) radius(1) radius(2) epsilon];
            params=IterativeEllipseFit(x,y,guess,[0 0 1 1 1]);
        elseif (epsilon==0) && isempty(radius)
            % under construction
        elseif isempty(radius)
            % fixed epsilon
        elseif isempty(epsilon)
            % fixed radius
        else % fixed radius and epsilon
            % under construction
        end
        
        if ishandle(hbutton)
            set(hbutton,'Enable','on');
        end                            
        theta=linspace(0,2*pi,1000);
        x0 = params(1);
        y0 = params(2);
        Ax = params(3);
        Ay = params(4);
        %epsilon = params(5);
        x = x0 + Ax * cos(theta);
        y = y0 + Ay * sin(theta - params(5));
        set(hline(2),'XData',x,'YData',y,'Visible','on');
    end

end