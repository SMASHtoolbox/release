function ROIstatistics(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,... % stopped here
            'Tag','ROIstatistics','ToolTipString','Region of interest (ROI) statistics',...
            'Cdata',local_graphic('ROIicon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.ROIstatistics=h;
    case 'hide'
        set(object.Button.ROIstatistics,'Visible','off');
    case 'show'
        set(object.Button.ROIstatistics,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        if strcmpi(state,'on')
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonDownFcn',@ButtonDown);
        else
            h=findobj(object.Handle,'Tag','ROIstatisticsBox');
            if ishandle(h)
                delete(h)
            end
        end
    end

end

%%
function ButtonDown(varargin)
% initial preparations
selection=get(gcbf,'SelectionType');
if ~strcmpi(selection,'normal')
    return
end

haxes=get(gcbf,'CurrentAxes');
tag=get(haxes,'Tag');
if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
    return
end

SourceFigure=ancestor(haxes,'figure');
h=findobj(SourceFigure,'Tag','ROIstatisticsBox');
if ishandle(h)
    delete(h);
end

% create ROI
point1=get(haxes,'CurrentPoint');
rbbox;
point2=get(haxes,'CurrentPoint');
x=[point1(1,1) point2(1,1)];
y=[point1(1,2) point2(1,2)];
if (diff(x)==0) || (diff(y)==0) % user made a zero area rectangle
    return
end
xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
rectangle('Parent',haxes,'Position',[xmin ymin xmax-xmin ymax-ymin],...
    'LineStyle','--','Tag','ROIstatisticsBox');

% extract information
hc=findobj(haxes,'Type','line','-or','Type','image');
N=numel(hc);
for ii=N:-1:1
    if strcmp(get(hc(ii),'Visible'),'off')
        continue
    end
    x=get(hc(ii),'XData');
    y=get(hc(ii),'YData');
    label={};
    label{end+1}=sprintf(' Horizontal range: %+g to %+g ',xmin,xmax);
    label{end+1}=sprintf(' Vertical range: %+g to %+g ',ymin,ymax);
    switch get(hc(ii),'Type')
        case 'line'
            % check for data inside ROI
            k=(x>=xmin)&(x<=xmax)&(y>=ymin)&(y<=ymax);
            if ~any(k)
                continue
            end
            x=x(k);
            y=y(k);
            % create ROI report
            fig=figure('NumberTitle','off','Name','ROI line statistics',...
                'IntegerHandle','off','HandleVisibility','callback',...
                'Tag','MinimalFigure:ROIstatistics',...
                'Toolbar','none','Menubar','none','DockControls','off',...
                'Units','pixels','Resize','off');            
            ha=axes('Parent',fig,'Box','on','Units','pixels',...
                'XTick',[],'YTick',[]);
            hl=line('Parent',ha,'XData',x,'YData',y);
            linkprop([hc(ii) hl],{'Color','LineWidth','LineStyle','Marker'});
            label{end+1}='';
            label{end+1}=sprintf(' Horizontal mean: %+g ',mean(x));
            label{end+1}=sprintf(' Horizontal deviation: %+g ',std(x));
            label{end+1}='';
            label{end+1}=sprintf(' Vertical mean: %+g ',mean(y));
            label{end+1}=sprintf(' Vertical deviation: %+g ',std(y));
            %a=polyfit(x(k),y(k),1);
            %label{end+1}=sprintf('Slope: %+g',a(1));
        case 'image'
            % check for data inside ROI
            z=get(hc(ii),'CData');
            [M,N]=size(z);
            x=linspace(x(1),x(end),N);
            y=linspace(y(1),y(end),M);
            kx=(x>=xmin)&(x<=xmax);
            if ~any(kx)
                continue
            end
            ky=(y>=ymin)&(y<=ymax);
            if ~any(ky)
                continue
            end
            x=x(kx);
            y=y(ky);
            z=z(ky,kx);
            if any(size(z)<1)
                continue
            end
            % create ROI report
            fig=figure('NumberTitle','off','Name','ROI image statistics',...
                'IntegerHandle','off','HandleVisibility','callback',...
                'Tag','MinimalFigure:ROIstatistics',...
                'Toolbar','none','Menubar','none','DockControls','off',...
                'Units','pixels','Resize','off');
            src_fig=ancestor(hc(ii),'figure');
            linkprop([src_fig fig],'ColorMap');
            ha=axes('Parent',fig,'Box','on','Units','pixels');
            hi=imagesc('Parent',ha,'Xdata',x,'YData',y,'CData',z);
            set(ha,'XTick',[],'YTick',[]);
            src_axes=ancestor(hc(ii),'axes');
            linkprop([src_axes ha],{'CLim','YDir'});
            label{end+1}='';
            label{end+1}=sprintf(' Image level mean: %+g ',mean(z(:)));
            label{end+1}=sprintf(' Image level deviation: %+g ',std(z(:)));
            try
                weight=mean(z,1);
                weight=weight/trapz(x,weight);
                CM=trapz(x(:),x(:).*weight(:));
            catch
                CM=nan;
            end
            label{end+1}='';
            label{end+1}=sprintf('Horizontal center: %+g',CM);
            try
                weight=mean(z,2);
                weight=weight/trapz(y,weight);
                CM=trapz(y(:),y(:).*weight(:));
            catch
                CM=nan;
            end
            label{end+1}=sprintf('Vertical center: %+g',CM);
    end
    % format report figure
    axis(ha,'tight');
    xlim(ha,[xmin xmax]);
    ylim(ha,[ymin ymax]);    
    ht=uicontrol('Parent',fig,'Style','text','Units','pixels',...
        'HorizontalAlignment','left','String',label,...
        'BackgroundColor',get(fig,'Color'));
    extent=get(ht,'Extent');
    Lx=extent(3);
    Ly=extent(4);
    set(ht,'Position',[Ly 0 Lx Ly]);
    gap=5; % pixels
    set(ha,'Position',[gap gap Ly-2*gap Ly-2*gap]);%,...
    %'PlotBoxAspectRatio',[(xmax-xmin) (ymax-ymin) 1]);
    pos=get(fig,'Position');
    pos(3)=Ly+Lx;
    pos(4)=Ly;
    set(fig,'Position',pos);
    setappdata(fig,'SourceFigure',SourceFigure);
end

end
