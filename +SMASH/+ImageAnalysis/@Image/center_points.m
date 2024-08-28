% CENTER_POINTS Centers a Image object based on centroid of points
%
% See also IMAGE

% created April 8, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 17, 2013 by Tommy Ao (Sandia National Laboratories)
%
function [object,x0,y0]=center_points(object)

h=view(object,'show');
set(h.figure,'Name','Center Image object')
title(h.axes,'Select centering points')

set(h.image,'ButtonDownFcn',@AddPoint);
hline(1)=line('Parent',h.axes,'Tag','SelectedPoints',...
    'XData',[],'YData',[],'Visible','off',...    
    'ButtonDownFcn',@AddPoint);
apply(object.GraphicOptions,hline);

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
[x0,y0]=updateGUI;
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
    function [x0,y0]=updateGUI()
        x=get(hline(1),'XData');
        y=get(hline(1),'YData');
        x0=mean(x);
        y0=mean(y);
    end

end