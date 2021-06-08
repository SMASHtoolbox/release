function slice(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','slice');
switch mode
    case 'on'
        haxes=ValidAxes(fig);
        if numel(haxes)>0
            data=get(toggle,'UserData');
            set(fig,'WindowButtonUpFcn',@sliceCallback,...
                'Pointer',data.pointer);            
        else
            set(toggle,'State','off'); % for user convenience
        end
    case 'off'
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end

function sliceCallback(src,varargin)

% verify image click and location
target=get(gcbf,'CurrentObject');
if ~strcmp(get(target,'Type'),'image')
    return
end

ha=ancestor(target,'axes');
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

subplot(2,1,2);
plot(y,interp2(x,y,z,x0,y,'linear'));
label=sprintf('Vertical slice @ %s = %g',xlab,x0);
title(label);
xlabel(ylab);

name=sprintf('Image slice created %s',datestr(now));
set(newfig,'Name',name);
