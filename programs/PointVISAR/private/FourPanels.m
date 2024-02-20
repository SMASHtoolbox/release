% FourPanels : create a pair of horizontal panels with slider sizing
%                    controlled by a slider
% only one FourPanels system can exist with any parent figure or uipanel

function [slider,panel]=FourPanels(varargin)

% make sure an even number of input arguments were given
if logical(rem(nargin,2))
    error('Unmatched number of input arguments')
end

% define variables
parent=[];
SliderValue=[];
SliderThickness=[];
PanelLabel={};

% sweep through input, updating the appropriate variables
for ii=1:2:nargin
    label=varargin{ii};
    switch lower(label)
        case 'parent'
            parent=varargin{ii+1};
        case 'slidervalue'
            SliderValue=varargin{ii+1};
        case 'sliderthickness' % pixels
            SliderThickness=varargin{ii+1};
        case 'panellabel'
            PanelTag=varargin{ii+1};
        otherwise
            msg2=' is not a valid field name';
            error([label msg2]);
    end
end

% apply default values as necessary
if isempty(parent)
    parent=gcf;
end
if isempty(SliderValue)
    SliderValue=[0.5 0.5 0.5];
end
if isempty(SliderThickness)
    SliderThickness=25;
end
if isempty(PanelLabel)
    PanelLabel={'TopLeft','BottomLeft','TopRight','BottomRight'};
end

% see if a FourPanels system already exists
SliderTag='FourPanelSlider';
main=findobj(parent,'Style','slider','Tag',SliderTag);
if ishandle(main) % update FourPanels system
    data=get(main,'UserData');
    for ii=1:numel(data.slider)
        set(data.slider(ii),'Value',SliderValue(ii));
    end
    PositionPanels(parent,[]);
else % create FourPanels system
    figcolor=get(parent,'Color');
    colorshift=0.05;
    for ii=1:3
        leftcolor(ii)=min([1 figcolor(ii)+colorshift]);
        rightcolor(ii)=max([0 figcolor(ii)-colorshift]);
    end 
    % panel sizing sliders
    slider(1)=uicontrol('Style','slider','Tag',SliderTag,...
        'Value',SliderValue(1),'Callback',@PositionPanels);
    slider(2)=uicontrol('Style','slider',...
        'Value',SliderValue(2),'Callback',@PositionPanels);
    slider(3)=uicontrol('Style','slider',...
        'Value',SliderValue(3),'Callback',@PositionPanels);
   % panels 
   for ii=1:numel(PanelLabel)
        panel(ii)=uipanel('Parent',parent,...
            'Tag',PanelLabel{ii},'Units','pixels');
        %detail(ii)=uicontrol('Parent',panel(ii),'Style','pushbutton');
    end
    %set(detail,'String','+','FontWeight','bold',...
    %    'Units','characters','Position',[0 0 1 1],...
    %    'Tag','DetailButton',...
    %    'ToolTipString','Detail view','Units','pixels',...
    %    'Callback',@DetailButton);
    set([panel(1:2)],'BackgroundColor',leftcolor);
    set([panel(3:4)],'BackgroundColor',rightcolor)
    % store information for later use
    data.slider=slider;
    data.panel=panel;
    %data.detail=detail;
    data.thickness=SliderThickness;
    set(slider(1),'UserData',data);
    % size everything for the first time
    ResizeFcn(parent,[]);
    % allow future resizing
    set(parent,'ResizeFcn',@ResizeFcn);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=ResizeFcn(src,eventdata)

SliderTag='FourPanelSlider';
fig=ancestor(src,'figure');
main=findobj(fig,'Tag',SliderTag);
data=get(main,'UserData');

slider=data.slider;
thickness=data.thickness;

FigUnits=get(fig,'Units');
set(fig,'Units','pixels');
figpos=get(fig,'Position');
set(gcf,'Units',FigUnits);

pos=[0 0 figpos(3) thickness];
set(slider(1),'Position',pos);

pos(2)=thickness;
pos(3)=thickness;
pos(4)=figpos(4)-pos(2);
set(slider(2),'Position',pos);

pos(1)=figpos(3)-pos(3);
set(slider(3),'Position',pos);
PositionPanels(src,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=PositionPanels(src,eventdata)

% find the main slider
SliderTag='FourPanelSlider';
fig=ancestor(src,'figure');
main=findobj(fig,'Tag',SliderTag);
data=get(main,'UserData');

% determine slider settings
slider=data.slider;
for ii=1:numel(slider);
    value(ii)=get(slider(ii),'Value');
end

% determine the working area
pos1=get(slider(1),'Position');
pos2=get(slider(2),'Position');
pos3=get(slider(3),'Position');

x0=pos2(1)+pos2(3);
Lx=pos3(1)-x0;
Ly=pos3(4); % should be the same as pos2(4);

% left panel positions
Lx1=value(1)*Lx;
Ly2=value(2)*Ly;
Ly1=Ly-Ly2;
y0=pos2(2)+Ly2;
PanelPosition{1}=[x0 y0 Lx1 Ly1];
y0=pos2(2);
PanelPosition{2}=[x0 y0 Lx1 Ly2];

% right panel positions
x0=x0+Lx1;
Lx2=Lx-Lx1;
Ly2=value(3)*Ly;
Ly1=Ly-Ly2;
y0=pos3(2)+Ly2;
PanelPosition{3}=[x0 y0 Lx2 Ly1];
y0=pos3(2);
PanelPosition{4}=[x0 y0 Lx2 Ly2];

% position the panels
panel=data.panel;
for ii=1:numel(panel)
    pos=PanelPosition{ii};
    if all(pos(3:4)>0)
        set(panel(ii),'Position',pos,'Visible','on');
   
        %detailpos=get(data.detail(ii),'Position');
        %LD=max(detailpos(3:4));
        %detailpos(1)=pos(3)-LD;
        %detailpos(2)=pos(4)-LD;
        %detailpos(3:4)=LD;
        %set(data.detail(ii),'Position',detailpos,'Visible','on');
    else
        set(panel(ii),'Visible','off');
        %set(data.detail(ii),'Visible','off');
    end
end