% QuadratureScreen: 

%
function fig=QuadratureScreen(oldfig)

% allocate mising input
if nargin<1
    oldfig='';
end

% create figure (if necessary)
tag='THRIVE_QuadratureScreen';
fig=findall(0,'Type','figure','Tag',tag);
if isempty(fig)
    fig=createGUI('Tag',tag);
end

% determine how figure was called
if isempty(oldfig)
    return
end
switch get(oldfig,'Tag');
    case {'THRIVE_LoadScreen','THRIVE_EllipseScreen'}
        % get load screen handles        
        srcfig=findall(0,'Type','figure','Tag','THRIVE_LoadScreen');
        hsrc=guihandles(srcfig);        
        % characterize quadrature ellipse
        tbound(1)=get(hsrc.CharacterizationTime1,'UserData');
        tbound(2)=get(hsrc.CharacterizationTime2,'UserData');        
        time=get(hsrc.D1,'XData');
        ii=(time>=min(tbound)) & (time<=max(tbound));
        D1=get(hsrc.D1,'YData');  D1=D1(ii);        
        D2=get(hsrc.D2,'YData');  D2=D2(ii);       
        D3=get(hsrc.D3,'YData');  D3=D3(ii);
        choice=findall(hsrc.CharacterizationMenu,'Checked','on');                      
        switch get(choice,'Tag')
            case 'ideal'
                baseline=[0 0 0]; % B1 B2 B3
                amplitude=[1 1 1]; % A1 A2 A3
                beta=[120 120]; % betaplus betaminus                
                ratio=[1 1]; % R12 R13
            case 'ellipse'
                prev=findall(0,'Type','figure','Tag','THRIVE_EllipseScreen');
                hprev=guihandles(prev);
                baseline(1)=ReadEditBox(hprev.D1baseline);
                baseline(1)=ReadEditBox(hprev.D1baseline);
                baseline(2)=ReadEditBox(hprev.D2baseline);
                baseline(3)=ReadEditBox(hprev.D3baseline);
                amplitude(1)=ReadEditBox(hprev.D1amplitude);
                amplitude(2)=ReadEditBox(hprev.D2amplitude);
                amplitude(3)=ReadEditBox(hprev.D3amplitude);
                beta(1)=ReadEditBox(hprev.betaplus);
                beta(2)=ReadEditBox(hprev.betaminus);
                ratio(1)=ReadEditBox(hprev.R12);
                ratio(2)=ReadEditBox(hprev.R13);
            case 'beamblock'
                % TBD
        end
        beta=beta*(pi/180); % convert degrees to radians
        [Dx,Dy]=QuadratureReduction(D1,D2,D3,baseline,amplitude,ratio,beta);
        fitparams=DirectEllipseFit(Dx,Dy);
        % store analysis and fit parameters
        h=guihandles(fig);
        data=get(h.ControlPanel,'UserData');
        data.baseline=baseline;
        data.amplitude=amplitude;
        data.ratio=ratio;
        data.beta=beta;
        data.fitparams=fitparams;
        set(h.ControlPanel,'UserData',data);
        % update screen
        set(h.HorizontalCenter,'String',num2str(fitparams(1)/fitparams(3)*100,'%+.2f'));
        set(h.VerticalCenter,'String',num2str(fitparams(2)/fitparams(4)*100,'%+.2f'));
        set(h.AspectRatio,'String',num2str(fitparams(3)/fitparams(4)*100,'%.2f'));
        set(h.QuadratureError,'String',num2str(fitparams(5)*(180/pi),'%+.2f')); 
        GenerateQuadrature(fig);        
    case 'THRIVE_ResultsScreen'
        % do something
end
MatchFigures(oldfig,fig);
figure(fig);

%%%%%%%%%%%%%%
% create GUI %
%%%%%%%%%%%%%%
function fig=createGUI(varargin)

% probe primary monitor size
monpos=get(0,'MonitorPositions');
monpos=monpos(1,:);
monLx=monpos(3)+monpos(1)-1;
monLy=monpos(4)+monpos(2)-1;

% create figure
name=aboutTHRIVE('name');
fig=MinimalFigure('Visible','off','units','pixels',...
    'NumberTitle','off','Name',name,'IntegerHandle','off',...
    varargin{:});
[h,pos]=textlabel(fig,[0 0],repmat('M',[1 80]));
delete(h);
data.Lx=pos(3);
data.Ly=0.80*monLy;
x0=(monLx-data.Lx)/2;
y0=(monLy-data.Ly)/2;
set(fig,'Position',[x0 y0 data.Lx data.Ly]);

data.ymargin=0.5*pos(4);
data.xmargin=data.ymargin;
data.ygap=data.ymargin/4;

% create uimenus
hm=uimenu(fig,'Label','Program');
uimenu(hm,'Label','Start over',...
    'Tag','StartOver','Callback',@StartOver);
uimenu(hm,'Label','Exit','Separator','on','Callback','close(gcbf)');

hm=uimenu(fig,'Label','Help');
uimenu(hm,'Label','About THRIVE','Callback',{@aboutTHRIVE,fig});
uimenu(hm,'Label','Quadrature signals','Callback',@HelpWindow);

% create control panel
hpanel(1)=custom_uipanel('Parent',fig,'Tag','ControlPanel');
number0=' +0.00000E+00 ';
data.ellipse=[];

labelA={'Horizontal centering (%)=','Vertical centering (%)='};
[maxchar,kmaxA]=max(cellfun(@numel,labelA));
labelB={'Aspect ratio (%)=','Quadrature error (deg)='};
[maxchar,kmaxB]=max(cellfun(@numel,labelB));

pos(1)=data.xmargin;
pos(2)=0;
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String',labelA{1},'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,number0,...
    'Tag','HorizontalCenter','String',0,'HorizontalAlignment','left');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,labelB{kmaxB},...
    'String',labelB{1},'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,number0,...
    'Tag','AspectRatio','String',100,'HorizontalAlignment','left');

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String',labelA{2},'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,number0,...
    'Tag','VerticalCenter','String',0,'HorizontalAlignment','left');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,labelB{kmaxB},...
    'String',labelB{2},'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,number0,...
    'Tag','QuadratureError','String',0,'HorizontalAlignment','left');

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,'Display range: ');
pos(1)=pos(1)+pos(3);
value=1;
[h,pos]=radiobutton(hpanel(1),pos,'Characterization',...
    'Tag','DisplayCharacterization','Callback',@GenerateQuadrature,...
    'Value',value,'UserData',value);
pos(1)=pos(1)+pos(3);
value=0;
[h,pos]=radiobutton(hpanel(1),pos,'Experiment',...
    'Tag','DisplayExperiment','Callback',@GenerateQuadrature,...
    'Value',value,'UserData',value);

panelpos=get(hpanel(1),'Position');
offset=abs(pos(2));
panelpos(4)=pos(4)+offset+2*data.ymargin;
hc=get(hpanel(1),'Children');
right=0;
for k=1:numel(hc)
    pos=get(hc(k),'Position');
    pos(2)=pos(2)+offset+data.ymargin;
    set(hc(k),'Position',pos);
    right=max([right pos(1)+pos(3)]);
end
panelpos(3)=right+data.xmargin;
set(hpanel(1),'Position',panelpos,'UserData',data);

% create plot panel
hpanel(2)=custom_uipanel('Parent',fig,'Tag','PlotPanel');
set(hpanel(2),'BorderType','line');
ha=axes('Parent',hpanel(2),'Tag','QuadraturePlot',...
    'Units','normalized','OuterPosition',[0 0 1 1],...
    'Box','on');
line('Parent',ha,'Tag','data1');
line('Parent',ha,'Tag','data2');

choice={'Signals','Ellipse'};
value=2;
popupmenu(hpanel(2),[],choice,...
    'Tag','PlotSelect','Callback',@GenerateQuadrature,...
    'Value',value,'UserData',value);

h=uicontrol('Parent',hpanel(2),'Tag','ClonePlot',...
    'String',' clone ','Callback',@ClonePlot,'Units','pixels',...
    'ToolTipString','Clone plot to separate window');
extent=get(h,'Extent');
set(h,'Position',extent);

% create next/previous buttons
h=custom_uicontrol('Parent',fig,'Style','pushbutton',...
    'Tag','Previous','String',' < Previous ','Callback',@PreviousButton);
pos=get(h,'Position');
h=custom_uicontrol('Parent',fig,'Style','pushbutton',...
    'Tag','Next','String',' Next > ','Callback',@NextButton);
set(h,'Position',pos);
custom_uicontrol('Parent',fig,'Style','text',...
    'Tag','GUIlabel','String','Quadrature signals','FontWeight','bold',...
    'BackgroundColor',get(fig,'Color'));

% final items
set(fig,'ResizeFcn',@ResizeFcn);
NudgeTextBoxes(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure resize function %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResizeFcn(src,varargin)

% get handles and data
fig=ancestor(src,'figure');
h=guihandles(fig);
data=get(h.ControlPanel,'UserData');

% enforce mininum dimensions
units=get(fig,'Units');
set(fig,'Units','pixels');
figpos=get(fig,'Position');
if figpos(3)<data.Lx
    figpos(3)=data.Lx;
end
if figpos(4)<data.Ly
    dy=data.Ly-figpos(4);
    figpos(2)=figpos(2)-dy;
    figpos(4)=data.Ly;
end
set(fig,'Position',figpos,'Units',units);

% position control panel
pos=get(h.ControlPanel,'Position');
pos(1)=0;
pos(2)=figpos(4)-pos(4);
pos(3)=figpos(3);
set(h.ControlPanel,'Position',pos);
y2=pos(2);

% position next/previous buttons (fixed height)
pos=get(h.Previous,'Position');
y0=pos(2);
pos(1)=2*data.xmargin;
pos(2)=data.ymargin;
set(h.Previous,'Position',pos);
left=pos(1)+pos(3);

pos=get(h.Next,'Position');
pos(1)=figpos(3)-2*data.xmargin-pos(3);
pos(2)=data.ymargin;
set(h.Next,'Position',pos);
right=pos(1);

% position GUI label
pos=get(h.GUIlabel,'Position');
pos(1)=left;
pos(2)=pos(2)-y0+data.ymargin;
pos(3)=right-left;
set(h.GUIlabel,'Position',pos);
y1=pos(2)+pos(4)+data.ymargin;

% position plot panel
pos(1)=0;
pos(2)=y1;
pos(3)=figpos(3);
pos(4)=y2-y1;
set(h.PlotPanel,'Position',pos);

% position plot select popup
panelpos=get(h.PlotPanel,'Position');
border=get(h.PlotPanel,'BorderWidth');
pos=get(h.PlotSelect,'Position');
pos(1)=border;
pos(2)=panelpos(4)-pos(4)-border;
set(h.PlotSelect,'Position',pos);

% position clone plot button
panelpos=get(h.PlotPanel,'Position');
border=get(h.PlotPanel,'BorderWidth');
pos=get(h.ClonePlot,'Position');
pos(1)=panelpos(3)-pos(3)-border;
pos(2)=panelpos(4)-pos(4)-border;
set(h.ClonePlot,'Position',pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% quadrature generation callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GenerateQuadrature(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% verify state change and update radio buttons
srctype=get(src,'Type');
if strcmp(srctype,'uicontrol')
    oldvalue=get(src,'UserData');
    switch get(src,'Tag')
        case 'DisplayCharacterization'
            set(src,'Value',1);
            if oldvalue==1 % no change
                return
            end
            set(h.DisplayExperiment,'Value',0,'UserData',0);
            set(src,'UserData',1);
        case 'DisplayExperiment'
            set(src,'Value',1);
            if oldvalue==1 % no change
                return
            end
            set(h.DisplayCharacterization,'Value',0,'UserData',0);
            set(src,'UserData',1);
        case 'PlotSelect'
            value=get(src,'Value');
            if oldvalue==value % no change
                return
            end
            set(src,'UserData',value);
    end
end

% extract data from load screen
srcfig=findall(0,'Type','figure','Tag','THRIVE_LoadScreen');
hsrc=guihandles(srcfig);
if get(h.DisplayCharacterization,'Value')==1
    tbound(1)=get(hsrc.CharacterizationTime1,'UserData');
    tbound(2)=get(hsrc.CharacterizationTime2,'UserData');
else
    tbound(1)=get(hsrc.ExperimentTime1,'UserData');
    tbound(2)=get(hsrc.ExperimentTime2,'UserData');
end
time=get(hsrc.D1,'XData');
ii=(time>=min(tbound)) & (time<=max(tbound));
time=time(ii);
D1=get(hsrc.D1,'YData');   D1=D1(ii);
D2=get(hsrc.D2,'YData');   D2=D2(ii);
D3=get(hsrc.D3,'YData');   D3=D3(ii);

% calculate quadrature signals
data=get(h.ControlPanel,'UserData');
[Dx,Dy]=QuadratureReduction(D1,D2,D3,...
    data.baseline,data.amplitude,data.ratio,data.beta);

% update screen
value=get(h.PlotSelect,'Value');
label=get(h.PlotSelect,'String');
switch lower(label{value})
    case 'signals'
        set(h.QuadraturePlot,...
            'DataAspectRatioMode','auto','PlotBoxAspectRatioMode','auto');
        set(h.data1,'XData',time,'YData',Dx,...
            'Color',[0 0 1],'Marker','none',...
            'LineStyle','-','LineWidth',0.5);
        set(h.data2,'XData',time,'YData',Dy,...
            'Color',[0 0.5 0],'Marker','none',...
            'LineStyle','-','LineWidth',0.5);
        xlabel(h.QuadraturePlot,'Time');
        ylabel(h.QuadraturePlot,'Quadrature signals');
        clean_legend([h.data1 h.data2],'Dx','Dy','Location','best');
    case 'ellipse'
        set(h.QuadraturePlot,...
            'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);
        color=[0 1 0];              
        set(h.data1,'XData',Dx,'YData',Dy,...
            'Marker','o','LineStyle','none','MarkerSize',4,...
            'MarkerEdgeColor',color,'MarkerFaceColor',color);
        params=data.fitparams;      
        Nfit=500;
        phi=linspace(0,2*pi,Nfit);
        xfit=params(1)+params(3)*cos(phi);
        yfit=params(2)+params(4)*sin(phi-params(5));
        set(h.data2,'XData',xfit,'YData',yfit,...
            'Color',[0 0 0],'Marker','none','LineWidth',2);
        %,'LineStyle','--','LineWidth',2);
        xlabel(h.QuadraturePlot,'Dx');
        ylabel(h.QuadraturePlot,'Dy');        
        clean_legend([h.data1 h.data2],'data','fit','Location','best');        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% previous button callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PreviousButton(src,varargin)

fig=ancestor(src,'figure');

srcfig=findall(0,'Type','figure','Tag','THRIVE_LoadScreen');
hsrc=guihandles(srcfig);
choice=findall(hsrc.CharacterizationMenu,'Checked','on');
switch get(choice,'Tag')
    case 'ideal'
        LoadScreen(fig);
    case 'ellipse'
        EllipseScreen(fig);
    case 'beamblock'
        %
end
set(fig,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%
% next button callback %
%%%%%%%%%%%%%%%%%%%%%%%%
function NextButton(src,varargin)

% get handles
fig=ancestor(src,'figure');
%h=guihandles(fig);

% update current screen
%set(h.DisplayCharacterization,'Value',0,'UserData',0);
%set(h.DisplayExperiment,'Value',1,'UserData',0);
%set(h.PlotSelect,'Value',1);
%GenerateQuadrature(fig);

% move to next screen
ResultsScreen(fig);
set(fig,'Visible','off');