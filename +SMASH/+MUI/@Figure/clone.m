% created August 4, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 5, 2013 by Daniel Dolan
%   -legends and colorbars now cloned with their source axes
% revised May 15, 2014 by Daniel Dolan
%   -callbacks (button down, context, etc.) removed from cloned objects
function clone(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','Clone','ToolTipString','Clone plot to separate figure',...
            'Cdata',local_graphic('CloneIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.Clone=h;
    case 'hide'
        set(object.ToolButton.Clone,'Visible','off');
    case 'show'
        set(object.ToolButton.Clone,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        fig=object.Handle;
        if strcmpi(state,'on')
            haxes=findobj(fig,'Type','axes');
            if numel(haxes)==1
                MakeClone(haxes);
                return                        
            end
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonUpFcn',@ButtonUp);
        else
            set(src,'State','off');
            set(object.Handle,'Pointer','arrow','WindowButtonUpFcn',[]);
        end
    end

    function ButtonUp(varargin) 
        switch get(gcbf,'SelectionType')
            case 'extend'
                haxes=findobj(gcbf,'Type','axes','Visible','on');
            otherwise
                haxes=get(gcbf,'CurrentAxes');
        end
        for n=1:numel(haxes)
            tag=get(haxes(n),'Tag');
            if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
                continue
            end
            MakeClone(haxes(n));
        end
        if numel(haxes) > 1
            src=object.ToolButton.Clone;
            set(src,'State','off');
            set(object.Handle,'Pointer','arrow','WindowButtonUpFcn',[]);
        end
    end

end

function MakeClone(target)

% preparations
srcfig=ancestor(target,'figure');

% copy selected axes
name=sprintf('Axes clone created %s',datestr(now));
fig=figure('Name',name);
new=copyobj(target,fig);
set(new,'Units','normalized','OuterPosition',[0 0 1 1]);

h=findall(fig,'-not','DeleteFcn','');
for n=1:numel(h)
    if isprop(h(n),'DeleteFcn')
        set(h,'DeleteFcn','');
    end
end


% deal with legends
%label={};
htar=findobj(target,'Type','line');
hlegend=getappdata(target,'LegendPeerHandle');
if ~isempty(hlegend)
    try % new graphics system
        marked=hlegend.PlotChildren;
        N=numel(marked);
        index=nan(1,N);
        for n=1:N
            index(n)=find(htar == marked(n));
        end
        label=hlegend.String;
        location=hlegend.Location;
    catch % legacy graphics system
        data=get(hlegend,'UserData');
        %temp=findobj(srcfig,'Type','axes','Tag','legend');
        %for m=1:numel(temp)
        %    data=get(temp(m),'UserData');
        %    if isfield(data,'PlotHandle') && (data.PlotHandle==target)
        %        hlegend=temp(m);
        %        break
        %    end
        %end
        N=numel(data.handles);
        index=nan(1,N);
        for n=1:N
            index(n)=find(htar == data.handles(n));
        end
        label=data.lstrings;
        location=get(hlegend,'Location');
    end
    hnew=findobj(new,'Type','line');
    hnew=hnew(index);
    legend(hnew,label,'Location',location);
end

% deal with colorbars
h=findobj(srcfig,'Tag','Colorbar');
if numel(h)>0
    % find target axes boundaries
    TargetUnits=get(target,'Units');
    position=get(target,'OuterPosition');
    xb=position(1)+[0 position(3)];
    yb=position(2)+[0 position(4)];
    % determine if colorbar is fully inside
    for m=1:numel(h)
        units=get(h(m),'Units');
        set(h(m),'Units',TargetUnits);
        try
            pos=get(h(m),'OuterPosition'); % pre-2014b MATLAB
            set(h(m),'Units',units);
            xc=pos(1)+pos(3)/2;
            yc=pos(2)+pos(4)/2;
            if (xc<xb(1)) || (xc>xb(2)) || (yc<yb(1)) || (yc>yb(2))
                continue % no match
            end
        catch
           if getappdata(h(m),'TargetAxes') ~= target % post-2014b MATLAB
               continue
           end
        end
        % create matching colorbar
        location=get(h(m),'Location');
        hc=colorbar('peer',new,'Location',location);
        % carry labels
        label=get(get(h(m),'XLabel'),'String');
        xlabel(hc,label);
        label=get(get(h(m),'YLabel'),'String');
        ylabel(hc,label);
        label=get(get(h(m),'Title'),'String');
        title(hc,label);
    end
end

% remove callbacks
h=findobj(new);
name={'ButtonDownFcn','Callback','UIContextMenu'};
for n=1:numel(h)
    for m=1:numel(name)
        if isprop(h(n),name{m})
            set(h(n),name{m},'')
        end
    end
end

end