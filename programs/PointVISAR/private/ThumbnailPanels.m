% ThumbnailPanels :
function [slider,panel,label,button]=ThumbnailPanels(varargin)

% make sure an even number of input arguments were given
if logical(rem(nargin,2))
    error('Unmatched number of input arguments')
end

% define variables
parent=[];
SliderValue=[];
SliderThickness=[];
NumThumbs=[];
PanelLabel={};
ButtonLabel={};

% sweep through input, updating the appropriate variables
for ii=1:2:nargin
    varlabel=varargin{ii};
    switch lower(varlabel)
        case 'parent'
            parent=varargin{ii+1};
        case 'slidervalue'
            SliderValue=varargin{ii+1};
        case 'sliderthickness'
            SliderThickness=varargin{ii+1};
        case 'numthumbs'
            NumThumbs=varargin{ii+1};
        case 'panellabel'
            PanelLabel=varargin{ii+1};
        case 'buttonlabel'
            ButtonLabel=varargin{ii+1};
        otherwise
            msg2=' is not a valid field name';
            error([varlabel msg2]);
    end
end

% apply default values as necessary
if isempty(parent)
    parent=gcf;
end
if isempty(SliderValue)
    SliderValue=1/3;
end
if isempty(SliderThickness)
    SliderThickness=25;
end
if isempty(NumThumbs)
    NumThumbs=2;
end
if isempty(PanelLabel)
    PanelLabel={'Thumbnails','Main panel'};
end
if isempty(ButtonLabel)
    ButtonLabel={'select','select'};
end

% see if a ThumbnailPanels system already exists in the parent figure
SliderTag='ThumbnailPanelsSlider';
main=findobj(parent,'Style','slider','Tag',SliderTag);
if ishandle(main) % update ThumbnailPanels system
    data=get(main,'UserData');
    set(data.slider,'Value',SliderValue);
    PositionPanels(parent,[]);
else % create SplitPanels system
    figcolor=get(parent,'Color');
    colorshift=0.05;
    for ii=1:3
        thumbcolor(ii)=min([1 figcolor(ii)+colorshift]);
        maincolor(ii)=max([0 figcolor(ii)-colorshift]);
    end    
    % panel sizing slider
    slider=uicontrol('Style','slider','Tag',SliderTag,...
        'Value',SliderValue,'Callback',@PositionPanels);
    % thumbnail panels
    for ii=1:NumThumbs
        panel(ii)=uipanel('Parent',parent,'Units','pixels',...
            'BackgroundColor',thumbcolor);
    end
    % main panel
    panel(end+1)=uipanel('Parent',parent,'Units','pixels',...
        'BackgroundColor',maincolor);
    % labels and buttons
    for ii=1:2
        label(ii)=uicontrol('Style','text','Parent',parent,...
            'String',PanelLabel{ii},...
            'HorizontalAlignment','center');
        button(ii)=uicontrol('Style','pushbutton','Parent',parent,...
            'String',ButtonLabel{ii});
    end
    set([label(1) button(1)],'BackgroundColor',thumbcolor);
    set([label(2) button(2)],'BackgroundColor',maincolor);
    % store information for later use
    data.slider=slider;
    data.panel=panel;
    data.button=button;
    data.label=label;
    data.thickness=SliderThickness;
    set(slider,'UserData',data);
    % size everything the first time
    ResizeFcn(gcf,[]);
    % allow future resizing
    set(gcf,'ResizeFcn',@ResizeFcn);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=ResizeFcn(src,eventdata)

SliderTag='ThumbnailPanelsSlider';
fig=ancestor(src,'figure');
slider=findobj(fig,'Tag',SliderTag);
data=get(slider,'UserData');

thickness=data.thickness;

FigUnits=get(fig,'Units');
set(gcf,'Units','pixels');
figpos=get(fig,'Position');
set(gcf,'Units',FigUnits);

pos=[0 0 figpos(3) thickness];
set(slider,'Position',pos);

PositionPanels(src,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=PositionPanels(src,eventdata)

% find the main slider
SliderTag='ThumbnailPanelsSlider';
fig=ancestor(src,'figure');
slider=findobj(fig,'Tag',SliderTag);
data=get(slider,'UserData');

% determine slider settings
value=get(slider,'Value');

% determine the working area
FigUnits=get(gcf,'Units');
set(gcf,'Units','pixels');
figpos=get(gcf,'Position');
set(gcf,'Units',FigUnits);

pos=get(slider,'Position');

% position thumbnails, label, and buttons
N=numel(data.panel)-1;
x0=0;
Lx=value*figpos(3);
if Lx>0
    extent1=get(data.label(1),'Extent');
    extent2=get(data.button(1),'Extent');
    Ly=max([extent1(4) extent2(4)]);
    y0=figpos(4)-Ly;
    set(data.label(1),'Position',[x0 y0 Lx extent1(4)],'Visible','on');
    LxB=1.20*extent2(3);
    x0B=x0+Lx-LxB;
    set(data.button(1),'Position',[x0B y0 LxB extent2(4)],'Visible','on');

    y0=pos(2)+pos(4);
    Ly=figpos(4)-y0-Ly;
    Ly=Ly/N;
    y0=y0+(N-1)*Ly;
    for ii=1:N
        set(data.panel(ii),'Position',[x0 y0 Lx Ly]);
        y0=y0-Ly;
        %extent=get(data.detail(ii),'Extent');
        %detailpos=get(data.detail(ii),'Position');
        %LD=max(detailpos(3:4));
        %set(data.detail(ii),'Position',[Lx-LD Ly-LD LD LD]);
    end
    
    set(data.panel(1:end-1),'Visible','on')
    set(data.label(1),'Visible','on');
    set(data.button(1),'Visible','on');
    %set(data.detail(1:end-1),'Visible','on');
else
    set(data.panel(1:end-1),'Visible','off');
    set(data.label(1),'Visible','off');
    set(data.button(1:end-1),'Visible','off');
end

% position main panel, label
x0=x0+Lx;
Lx=(1-value)*figpos(3);
if Lx>0
    extent1=get(data.label(2),'Extent');
    extent2=get(data.button(2),'Extent');
    Ly=max([extent1(4) extent2(4)]);
    y0=figpos(4)-Ly;
    set(data.label(2),'Position',[x0 y0 Lx extent1(4)],'Visible','on');
    LxB=1.20*extent2(3);
    x0B=x0+Lx-LxB;
    set(data.button(2),'Position',[x0B y0 LxB extent2(4)],'Visible','on');

    y0=figpos(4)-Ly;
    set(data.label(2),'Position',[x0 y0 Lx Ly])
    
    y0=pos(2)+pos(4);
    Ly=figpos(4)-y0-Ly;
    set(data.panel(end),'Position',[x0 y0 Lx Ly]);
    %detailpos=get(data.detail(end),'Position');
    %LD=max(detailpos(3:4));
    %set(data.detail(end),'Position',[Lx-LD Ly-LD LD LD]);
    
    set(data.panel(end),'Visible','on');
    set(data.label(2),'Visible','on');
    set(data.button(2),'Visible','on');
    %set(data.detail(end),'Visible','on');
else
    set(data.panel(end),'Visible','off');
    set(data.label(2),'Visible','off');
    set(data.button(2),'Visible','off');
    %set(data.detail(end),'Visible','off');
end
