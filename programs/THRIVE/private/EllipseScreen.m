function fig=EllipseScreen(oldfig)

% allocate mising input
if nargin<1
    oldfig='';
end

% create figure (if necessary)
tag='THRIVE_EllipseScreen';
fig=findall(0,'Type','figure','Tag',tag);
if isempty(fig)
    fig=createGUI('Tag',tag);
end

% determine how figure was called
if isempty(oldfig)
    return
end
switch get(oldfig,'Tag');
    case {'THRIVE_LoadScreen'} % load characterization data
      srcfig=findall(0,'Type','figure','Tag','THRIVE_LoadScreen');
      hsrc=guihandles(srcfig);
      tbound(1)=get(hsrc.CharacterizationTime1,'UserData');
      tbound(2)=get(hsrc.CharacterizationTime2,'UserData');
      time=get(hsrc.D1,'XData');
      k=(time>=min(tbound)) & (time<=max(tbound));
      D1=get(hsrc.D1,'YData');   D1=D1(k);
      D2=get(hsrc.D2,'YData');   D2=D2(k);
      D3=get(hsrc.D3,'YData');   D3=D3(k);
      h=guihandles(fig);
      set(h.D1D2data,'XData',D1,'YData',D2);
      set(h.D1D3data,'XData',D1,'YData',D3);
    case 'THRIVE_QuadratureScreen'
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
uimenu(hm,'Label','Ellipse fitting','Callback',@HelpWindow);

% create control panel
hpanel(1)=custom_uipanel('Parent',fig,'Tag','ControlPanel');
%filename0=repmat('M',[1 50]);
number0=' +0.00000E+00 ';
data.ellipse=[];

pos(1)=data.xmargin;
pos(2)=0;
[h,pos]=pushbutton(hpanel(1),pos,' Guess parameters ',...
    'Tag','guess','Callback',@GuessParameters,...
    'ToolTipString','Guess ellise parameters (resets fixed values)');
pos(1)=pos(1)+pos(3)+2*data.xmargin;
[h,pos]=pushbutton(hpanel(1),pos,' Optimize parameters ',...
    'Tag','optimize','Callback',@OptimizeParameters,...
    'ToolTipString','Iteratively optimize parameters (fixed values remain constant)');

labelA={'D1 baseline=','D2 amplitude='};
[maxchar,kmaxA]=max(cellfun(@numel,labelA));

pos(1)=data.xmargin;
pos(2)=pos(2)-2*data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D1 baseline=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','D1baseline','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixD1baseline','Callback',@FixEditBox,'UserData',hedit);
pos(1)=pos(1)+pos(3)+data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D1 amplitude=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','D1amplitude','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixD1amplitude','Callback',@FixEditBox,'UserData',hedit);

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D2 baseline=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','D2baseline','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixD2baseline','Callback',@FixEditBox,'UserData',hedit);
pos(1)=pos(1)+pos(3)+data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D2 amplitude=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','D2amplitude','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixD2amplitude','Callback',@FixEditBox,'UserData',hedit);

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D3 baseline=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','D3baseline','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixD3baseline','Callback',@FixEditBox,'UserData',hedit);
pos(1)=pos(1)+pos(3)+data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D3 amplitude=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','D3amplitude','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixD3amplitude','Callback',@FixEditBox,'UserData',hedit);

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D2 lead (deg)=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','betaplus','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixbetaplus','Callback',@FixEditBox,'UserData',hedit);
pos(1)=pos(1)+pos(3)+data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,labelA{kmaxA},...
    'String','D3 lag (deg)=','HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','betaminus','String','','Callback',@UpdateFits);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'fix',...
    'Tag','fixbetaminus','Callback',@FixEditBox,'UserData',hedit);

pos(1)=data.xmargin;
pos(2)=pos(2)-2*data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos, 'Assume:',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
choice={'ref > target (D1)','ref < target (D1)'};
[hpop(1),pos]=popupmenu(hpanel(1),pos,choice,...
    'Tag','D1assumption','Callback',@UpdateFits,...
    'ToolTipString','Select D1 coupling assumption');
pos(1)=pos(1)+pos(3);
choice={'ref > target (D2)','ref < target (D2)'};
[hpop(2),pos]=popupmenu(hpanel(1),pos,choice,...
    'Tag','D2assumption','Callback',@UpdateFits,...
    'ToolTipString','Select D2 coupling assumption');
pos(1)=pos(1)+pos(3);
choice={'ref > target (D3)','ref < target (D3)'};
[hpop(3),pos]=popupmenu(hpanel(1),pos,choice,...
    'Tag','D3assumption','Callback',@UpdateFits,...
    'ToolTipString','Select D3 coupling assumption');
pos(1)=pos(1)+pos(3);
link.hpop=hpop;
[h,pos]=checkbox(hpanel(1),pos,'link',...
    'Tag','linkassumptions','Callback',@LinkAssumptions,'UserData',link,...
    'Value',1);
LinkAssumptions(h); % default to on

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,'R12=',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=textlabel(hpanel(1),pos,number0,...
    'Tag','R12','String','TBD','HorizontalAlignment','left',...
    'Callback',@ReadEditBox);
pos(1)=pos(1)+pos(3)+data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,'R13=',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=textlabel(hpanel(1),pos,number0,...
    'Tag','R13','String','TBD','HorizontalAlignment','left',...
    'Callback',@ReadEditBox);
pos(1)=pos(1)+pos(3);
[h,pos]=checkbox(hpanel(1),pos,'AC coupling',...
    'Tag','ACcoupling','Value',0,'Callback',@DetectorCoupling,...
    'ToolTipString','Check this box if measurement used AC coupled detectors');

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

ha=axes('Parent',hpanel(2),'Tag','D1D2plot',...
    'Units','normalized','OuterPosition',[0 0 0.5 1],...
    'FontUnits','points','FontSize',14,...
    'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1],'Box','on');
%color=repmat(2/3,[1 3]);
color=[0 1 0];
line('Parent',ha,'Tag','D1D2data',...
    'Marker','o','LineStyle','none','MarkerSize',4,...
    'MarkerEdgeColor',color,'MarkerFaceColor',color);
line('Parent',ha,'Tag','D1D2fit','XData',[],'YData',[],...
    'LineStyle','-','Marker','none','Color',[0 0 0],...
    'LineWidth',2,'Visible','off');
xlabel(ha,'D1');
ylabel(ha,'D2');
title(ha,'D1-D2 ellipse');

ha=axes('Parent',hpanel(2),'Tag','D1D3plot',...
    'Units','normalized','OuterPosition',[0.5 0 0.5 1],...
    'FontUnits','points','FontSize',14,...
    'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1],'Box','on');
line('Parent',ha,'Tag','D1D3data',...
        'Marker','o','LineStyle','none','MarkerSize',4,...
    'MarkerEdgeColor',color,'MarkerFaceColor',color);
line('Parent',ha,'Tag','D1D3fit','XData',[],'YData',[],...    
    'LineStyle','-','Marker','none','Color',[0 0 0],...
    'LineWidth',2,'Visible','off');
xlabel(ha,'D1');
ylabel(ha,'D3');
title(ha,'D1-D3 ellipse');

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
    'Tag','GUIlabel','String','Ellipse characterization','FontWeight','bold',...
    'BackgroundColor',get(fig,'Color'));

% final items
set(fig,'ResizeFcn',@ResizeFcn);
NudgeTextBoxes(fig);
NudgePopupMenus(fig);

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

% position clone plot button
panelpos=get(h.PlotPanel,'Position');
border=get(h.PlotPanel,'BorderWidth');
pos=get(h.ClonePlot,'Position');
pos(1)=panelpos(3)-pos(3)-border;
pos(2)=panelpos(4)-pos(4)-border;
set(h.ClonePlot,'Position',pos);

%%%%%%%%%%%%%%%%%%%%%%%
% fix button callback %
%%%%%%%%%%%%%%%%%%%%%%%
function FixEditBox(src,varargin)

target=get(src,'UserData');
if get(src,'Value')==1 % button on
    set(target,'Enable','off'); % disable edit box
else % button off
    set(target,'Enable','on'); % enable edit box
end

%%%%%%%%%%%%%%%%%%%%%%%%
% link button callback %
%%%%%%%%%%%%%%%%%%%%%%%%
function LinkAssumptions(src,varargin)

link=get(src,'UserData');
if get(src,'Value')==1 % button on
    link.handle=linkprop(link.hpop,'Value'); % link assumptions
    set(src,'UserData',link);
else % button off
    removeprop(link.handle,'Value');  % unlink assumptions
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set detector coupling (AC/DC) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetectorCoupling(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

hass=[h.D1assumption h.D2assumption h.D3assumption h.linkassumptions];
hR=[h.R12 h.R13];
if get(src,'Value')==1 % AC coupling
    set(hass,'Enable','off');
    for k=1:numel(hR) % fix vertical position
        string=get(hR(k),'String');
        set(hR(k),'String','');
        pos=get(hR(k),'Position');
        extent=get(hR(k),'Extent');
        pos(2)=pos(2)+2*extent(4);
        set(hR(k),'Position',pos,'String',string,...
            'String','1','UserData',1);
    end    
    set(hR,'Style','edit','BackgroundColor',[1 1 1]);
else % DC coupling
    set(hass,'Enable','on');
     for k=1:numel(hR) % fix vertical position
        string=get(hR(k),'String');
        set(hR(k),'String','');
        pos=get(hR(k),'Position');
        extent=get(hR(k),'Extent');
        pos(2)=pos(2)-2*extent(4);
        set(hR(k),'Position',pos,'String',string);       
    end    
    parent=get(h.R12,'Parent');
    bgcolor=get(parent,'BackgroundColor');
    set(hR,'Style','text','BackgroundColor',bgcolor);    
    refresh(fig);
end

UpdateFits(src,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%
% update fit callback %
%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFits(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

Nfit=500; % number of display points in ellise fits

% D1-D2 fit
x0=ReadEditBox(h.D1baseline);
Lx=ReadEditBox(h.D1amplitude);
y0=ReadEditBox(h.D2baseline);
Ly=ReadEditBox(h.D2amplitude);
betaplus=ReadEditBox(h.betaplus);
epsilon=(betaplus-90)*(pi/180);
params=[x0 y0 Lx Ly epsilon];
if numel(params)==5
    phi=linspace(0,2*pi,Nfit);
    xfit=params(1)+params(3)*cos(phi);
    yfit=params(2)+params(4)*sin(phi-params(5));
    set(h.D1D2fit,'XData',xfit,'YData',yfit,'Visible','on');
else
    set(h.D1D2fit,'Visible','off');    
end

% D1-D3 fit
z0=ReadEditBox(h.D3baseline);
Lz=ReadEditBox(h.D3amplitude);
betaminus=ReadEditBox(h.betaminus);
epsilon=(betaminus-90)*(pi/180);
params=[x0 z0 Lx Lz epsilon];
if numel(params)==5
    phi=linspace(0,2*pi,Nfit);
    xfit=params(1)+params(3)*cos(phi);
    yfit=params(2)+params(4)*sin(phi-params(5));
    set(h.D1D3fit,'XData',xfit,'YData',yfit,'Visible','on');
else
    set(h.D1D3fit,'Visible','off');
end

% parameter ratios
if get(h.ACcoupling,'Value')==1 % AC coupling
    % do nothing
else % DC coupling
    contrast=[Lx/x0 Ly/y0 Lz/z0];
    if any(contrast>1)
        warndlg('Unphysical contrast estimates set to unity',...
            'Unphysical contrast');
        contrast(contrast>1)=1;
    end
    if numel(contrast)==3
        rootsign='+++';
        choice={'+','-'};
        value=get(h.D1assumption,'Value');
        rootsign(1)=choice{value};
        value=get(h.D2assumption,'Value');
        rootsign(2)=choice{value};
        value=get(h.D3assumption,'Value');
        rootsign(3)=choice{value};
        ratio=ParameterRatios(contrast,rootsign);
        sigfig=5;
        set(h.R12,'String',num2str(ratio(1),sigfig));
        set(h.R13,'String',num2str(ratio(2),sigfig));
    else
        set(h.R12,'String','TBD');
        set(h.R13,'String','TBD');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% guess parameter callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GuessParameters(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% extract data
D1=get(h.D1D2data,'XData');
D2=get(h.D1D2data,'YData');
D3=get(h.D1D3data,'YData');

% perform and interpret ellipse fits
params1=DirectEllipseFit(D1,D2);
params2=DirectEllipseFit(D1,D3);
D1baseline=mean([params1(1) params2(1)]);
D2baseline=params1(2);
D3baseline=params2(2);
D1amplitude=mean([params1(3) params2(3)]);
D2amplitude=params1(4);
D3amplitude=params2(4);
betaplus=params1(5)*(180/pi)+90;
betaminus=params2(5)*(180/pi)+90;

% update edit boxes
sigfig=5;
set(h.D1baseline,'UserData',D1baseline,'String',num2str(D1baseline,sigfig));
set(h.D1amplitude,'UserData',D1amplitude,'String',num2str(D1amplitude,sigfig));
set(h.D2baseline,'UserData',D2baseline,'String',num2str(D2baseline,sigfig));
set(h.D2amplitude,'UserData',D2amplitude,'String',num2str(D2amplitude,sigfig));
set(h.D3baseline,'UserData',D3baseline,'String',num2str(D3baseline,sigfig));
set(h.D3amplitude,'UserData',D3amplitude,'String',num2str(D3amplitude,sigfig));
set(h.betaplus,'UserData',betaplus,'String',num2str(betaplus,sigfig));
set(h.betaminus,'UserData',betaminus,'String',num2str(betaminus,sigfig));

% update fit plots
handle=get(h.D1baseline,'Callback');
feval(handle,h.D1baseline);

% undo all fixed settings
tag=fields(h);
for k=1:numel(tag)
    if strncmp(tag{k},'fix',3)
        set(h.(tag{k}),'Value',0);
        handle=get(h.(tag{k}),'Callback');
        feval(handle,h.(tag{k}));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optimize parameter callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OptimizeParameters(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% extract data
D1=get(h.D1D2data,'XData');
D2=get(h.D1D2data,'YData');
D3=get(h.D1D3data,'YData');


%guess=zeros(1,8);
guess=cell(1,8);
guess{1}=get(h.D1baseline,'UserData');
guess{2}=get(h.D1amplitude,'UserData');
guess{3}=get(h.D2baseline,'UserData');
guess{4}=get(h.D2amplitude,'UserData');
guess{5}=get(h.D3baseline,'UserData');
guess{6}=get(h.D3amplitude,'UserData');
guess{7}=get(h.betaplus,'UserData');
guess{8}=get(h.betaminus,'UserData');
for k=1:8
    if isempty(guess{k})
        msg{1}='ERROR: missing optimization guess';
        msg{2}='All parameters need a guess value for optimization';
        msg=sprintf('%s\n',msg{:});
        errordlg(msg,'Missing optimization guess');
    return
    end
end
guess=cell2mat(guess);
guess(7:8)=(guess(7:8)-90)*(pi/180);

fixed=zeros(1,8);
fixed(1)=get(h.fixD1baseline,'Value');
fixed(2)=get(h.fixD1amplitude,'Value');
fixed(3)=get(h.fixD2baseline,'Value');
fixed(4)=get(h.fixD2amplitude,'Value');
fixed(5)=get(h.fixD3baseline,'Value');
fixed(6)=get(h.fixD3amplitude,'Value');
fixed(7)=get(h.fixbetaplus,'Value');
fixed(8)=get(h.fixbetaminus,'Value');
fixed=logical(fixed);

% perform and interpret ellipse fits
params=IterativeEllipseFit(D1,D2,D3,guess,fixed);
D1baseline=params(1);
D1amplitude=params(2);
D2baseline=params(3);
D2amplitude=params(4);
D3baseline=params(5);
D3amplitude=params(6);
betaplus=params(7)*(180/pi)+90;
betaminus=params(8)*(180/pi)+90;

% update edit boxes
sigfig=5;
set(h.D1baseline,'UserData',D1baseline,'String',num2str(D1baseline,sigfig));
set(h.D1amplitude,'UserData',D1amplitude,'String',num2str(D1amplitude,sigfig));
set(h.D2baseline,'UserData',D2baseline,'String',num2str(D2baseline,sigfig));
set(h.D2amplitude,'UserData',D2amplitude,'String',num2str(D2amplitude,sigfig));
set(h.D3baseline,'UserData',D3baseline,'String',num2str(D3baseline,sigfig));
set(h.D3amplitude,'UserData',D3amplitude,'String',num2str(D3amplitude,sigfig));
set(h.betaplus,'UserData',betaplus,'String',num2str(betaplus,sigfig));
set(h.betaminus,'UserData',betaminus,'String',num2str(betaminus,sigfig));

% update fit plots
handle=get(h.D1baseline,'Callback');
feval(handle,h.D1baseline);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% previous button callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PreviousButton(src,varargin)

fig=ancestor(src,'figure');
LoadScreen(fig);
set(fig,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%
% next button callback %
%%%%%%%%%%%%%%%%%%%%%%%%
function NextButton(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% make sure everything is ready before moving on
flag(1)=strcmp(get(h.D1D2fit,'Visible'),'off');
flag(2)=strcmp(get(h.D1D3fit,'Visible'),'off');
flag(3)=strcmp(get(h.R12,'String'),'TBD');
flag(4)=strcmp(get(h.R13,'String'),'TBD');
if all(flag)   % move to next screen
    msg{1}='ERROR: incomplete characterization';
    msg{2}='Please finish ellipse fits before proceeding.';
    msg=sprintf('%s\n',msg{:});
    errordlg(msg,'Incomplete characterization');
    return
end

% move to the next screen
QuadratureScreen(fig);
set(fig,'Visible','off');