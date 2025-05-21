function slice(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','Slice','ToolTipString','Slice image',...
            'Cdata',local_graphic('SliceIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.Slice=h;
    case 'hide'
        set(object.Button.Slice,'Visible','off');
    case 'show'
        set(object.Button.Slice,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        %fig=object.Handle;
        if strcmpi(state,'on')
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonUpFcn',@ButtonUp);
        end
    end

    function ButtonUp(varargin)        
        selection=get(gcbf,'SelectionType');
        if ~strcmpi(selection,'normal')
            return;
        end
        haxes=get(gcbf,'CurrentAxes');
        tag=get(haxes,'Tag');
        if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
            return
        end
        himage=get(gcbf,'CurrentObject');
        type=get(himage,'type');
        if ~strcmpi(type,'image')
            return
        end
        SliceImage(himage);
    end

end

function SliceImage(target)

ha=ancestor(target,'axes');
bound=caxis(ha);
current=get(ha,'CurrentPoint');
x0=current(1,1);
y0=current(1,2);

hlabel=get(ha,'XLabel');
xlab=get(hlabel,'String');
if isempty(xlab)
    xlab='x';
end
hlabel=get(ha,'YLabel');
ylab=get(hlabel,'String');
if isempty(ylab)
    ylab='y';
end

% extract target data and plot in new figure
z=get(target,'CData');
[N,M]=size(z);
x=get(target,'XData');
if numel(x)~=M
    x=linspace(x(1),x(end),M);
end
y=get(target,'YData');
if numel(y)~=N
    y=linspace(y(1),y(end),N);
end

newfig=figure;
subplot(2,1,1);
plot(x,interp2(x,y,z,x,y0,'linear'));
label=sprintf('Horizontal slice @ %s = %g',ylab,y0);
title(label);
xlabel(xlab);
ylim(bound);

subplot(2,1,2);
plot(y,interp2(x,y,z,x0,y,'linear'));
label=sprintf('Vertical slice @ %s = %g',xlab,x0);
title(label);
xlabel(ylab);
ylim(bound);

name=sprintf('Image slice created %s',datestr(now));
set(newfig,'Name',name);

setappdata(newfig,'SourceFigure',gcbf);

end