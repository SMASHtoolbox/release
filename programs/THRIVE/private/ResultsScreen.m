% ResultsScreen: 

%
function fig=ResultsScreen(oldfig)

% allocate mising input
if nargin<1
    oldfig='';
end

% create figure (if necessary)
tag='THRIVE_ResultsScreen';
fig=findall(0,'Type','figure','Tag',tag);
if isempty(fig)        
    fig=createGUI('Tag',tag);
end
  
% determine how figure was called
if isempty(oldfig)
    return
end
switch get(oldfig,'Tag');           
    case 'THRIVE_QuadratureScreen'
        % extract information from quadrature screen
        hprev=guihandles(oldfig);
        data=get(hprev.ControlPanel,'UserData');        
        % store fringe data
        h=findobj(fig,'Tag','PlotPanel');
        set(h,'UserData',data);
        GenerateResults(fig);
end
MatchFigures(oldfig,fig);

% give the axes a helpful title
figA=findobj(0,'Type','figure','Tag','THRIVE_LoadScreen');
hedit=findobj(figA,'Tag','File1Edit');
label=get(hedit,'String');
[pname,label,ext]=fileparts(label);
label=sprintf('Analysis of %s%s',label,ext);
haxes=findobj(fig,'Tag','ResultPlot');
title(haxes,label,'Interpreter','none');

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

hm=uimenu(fig,'Label','Interferometer type','Tag','InterferometerMenu');
uimenu(hm,'Label','Displacement','Checked','on',...
    'Tag','displacement','Callback',@InterferometerType);
uimenu(hm,'Label','Velocity',...
    'Tag','velocity','Callback',@InterferometerType);
%uimenu(hm,'Label','Differential displacement','Tag','difference',...
%    'Enable','off');

hm=uimenu(fig,'Label','Export options','Tag','ExportOptionsMenu');
%uimenu(hm,'Label','Fringe history (t f)');
uimenu(hm,'Label','Quadrature signals (t Dx Dy RV)',...
    'Tag','quadrature','Callback',@ExportOptions);
uimenu(hm,'Label','Position history (t x)',...
    'Tag','position','Callback',@ExportOptions);
uimenu(hm,'Label','Velocity history (t v)',...
    'Tag','velocity','Callback',@ExportOptions);
uimenu(hm,'Label','Acceleration history (t a)',...
    'Tag','acceleration','Callback',@ExportOptions);
uimenu(hm,'Label','Velocity/position history (t v x)',...
    'Tag','velocity+position','Callback',@ExportOptions,...
    'Checked','on');
uimenu(hm,'Label','Full history (t Dx Dy RV v x a)',...
    'Tag','full','Callback',@ExportOptions);

hm=uimenu(fig,'Label','Help');
uimenu(hm,'Label','About THRIVE','Callback',{@aboutTHRIVE,fig});
uimenu(hm,'Label','Viewing/exporting results','Callback',@HelpWindow);

% create control panel
hpanel(1)=custom_uipanel('Parent',fig,'Tag','ControlPanel');
filename0=repmat('M',[1 50]);
number0=' +0.00000E+00 ';

pos(1)=data.xmargin;
pos(2)=0;
%tooltip='Displacement/velocity per fringe, depending on interferometer configuration';
tooltip='Displacement/velocity per fringe';
[h,pos]=textlabel(hpanel(1),pos,'Fringe constant=',...
    'HorizontalAlignment','right','ToolTipString',tooltip);
pos(1)=pos(1)+pos(3);
DPF=(1550e-9)/2;
[h,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','FringeConstant','Callback',@ReadEditBox,...
    'String',DPF,'UserData',DPF,...
    'ToolTipString','Use (1550E-9/2) [meters] for standard PDV');
pos(1)=pos(1)+pos(3)+5*data.xmargin;
[h,pos]=pushbutton(hpanel(1),pos,'  Update plot  ',...
    'Callback',@GenerateResults);

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,'Fit order=',...
    'ToolTipString','Polynomial fit order (1=linear)');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,number0,...
    'String','','Tag','SGorder',...
    'Callback',@ReadEditBox);
pos(1)=pos(1)+pos(3)+2*data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,'# points=',...
    'ToolTipString','Number of points in polynomial fit');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,number0,...
    'String','','Tag','SGnumpoints',...
    'Callback',@ReadEditBox);
pos(1)=pos(1)+pos(3)+2*data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,'Window size=',...
    'ToolTipString','Smoothing window size in time units');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,number0,...
    'String','','Tag','SGwindow','HorizontalAlignment','left');

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=pushbutton(hpanel(1),pos,' Export ',...
    'Callback',@ExportData);
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,filename0,...
    'Tag','ExportFileEdit','HorizontalAlignment','left',...
    'String','');
hedit=h;
pos(1)=pos(1)+pos(3);
[h,pos]=pushbutton(hpanel(1),pos,' select ',...
    'Tag','ExportFileSelect','Callback',{@SelectFile,hedit,'write'});

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
ha=axes('Parent',hpanel(2),'Tag','ResultPlot',...
    'Units','normalized','OuterPosition',[0 0 1 1],...
    'FontUnits','points','FontSize',14,...
    'Box','on');
xlabel('Time');
line('Parent',ha,'Tag','ResultLine');

%choice={'Fringe shift','Position','Velocity'};
%value=3; % % default to Velocity
%choice={'Fringe shift','Position','Velocity','Acceleration'};
choice={'Fringe shift','Return variation','Position','Velocity','Acceleration'};
value=3; % default to Position
popupmenu(hpanel(2),[],choice,...
    'Tag','PlotSelect','Callback',@GenerateQuadrature,...
    'Value',value,'Callback',@SelectVariable);

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
    'Tag','Next','String',' Next > ','Visible','off');
set(h,'Position',pos);
custom_uicontrol('Parent',fig,'Style','text',...
    'Tag','GUIlabel','String','Results','FontWeight','bold',...
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

%%%%%%%%%%%%%%%%%%%%%%%
% interferometer type %
%%%%%%%%%%%%%%%%%%%%%%%
function InterferometerType(src,varargin)

menu=get(src,'parent');
items=get(menu,'Children');
set(items,'Checked','off');
set(src,'Checked','on');

GenerateResults(src,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% export options callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportOptions(src,varargin)

menu=get(src,'parent');
items=get(menu,'Children');
set(items,'Checked','off');
set(src,'Checked','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% results generation callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GenerateResults(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig); 

% extract information from current screen
%value=get(h.PlotSelect,'Value');
%string=get(h.PlotSelect,'String');
%switch string{value}
%    case 'Acceleration'
%        maxderiv=2;
%    otherwise
%        maxderiv=1;
%end

Kfringe=get(h.FringeConstant,'UserData');
p1=get(h.SGorder,'UserData');
if isempty(p1)
    p1=1;
end
p2=get(h.SGnumpoints,'UserData');
if isempty(p2)
    p2=p1;
end
SGparams=[p1 p2];

% interpret fringe shift
data=get(h.PlotPanel,'UserData');
time=data.time;
T=(time(end)-time(1))/(numel(time)-1);
choice=findall(h.InterferometerMenu,'checked','on');
switch get(choice,'Tag')
    case 'displacement'        
        data.position=Kfringe*data.fringe;
        if p1<2 % allow first order smoothing for backwards compatibility 
            [data.position,data.velocity,SGparams]=...
                SmoothDerivative([0 1],SGparams,data.position,T);
            data.acceleration=zeros(size(data.position));
        else
            [data.position,data.velocity,data.acceleration,SGparams]=...
                SmoothDerivative([0 1 2],SGparams,data.position,T);
        end
    case 'velocity'
        data.velocity=Kfringe*data.fringe;
        [data.velocity,data.acceleration]=...
            SmoothDerivative([0 1],SGparams,data.velocity,T);
        index=isnan(data.velocity);
        data.velocity(index)=0;
        data.position=cumtrapz(data.velocity)*T;
        data.velocity(index)=nan;
    case 'difference'
        % TBD
end 

% update figure
set(h.SGorder,'UserData',SGparams(1),'String',num2str(SGparams(1)));
set(h.SGnumpoints,'UserData',SGparams(2),'String',num2str(SGparams(2)));
SGwindow=sprintf('%.6g',SGparams(2)*T);
set(h.SGwindow,'String',SGwindow);
set(h.PlotPanel,'UserData',data);
SelectVariable(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% screen update callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function SelectVariable(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);
data=get(h.PlotPanel,'UserData');

value=get(h.PlotSelect,'Value');
string=get(h.PlotSelect,'String');
switch string{value}
    case 'Fringe shift' 
        set(h.ResultLine,'XData',data.time,'YData',data.fringe);
    case 'Return variation'
        set(h.ResultLine,'XData',data.time,'YData',data.variation);
    case 'Position'
        set(h.ResultLine,'XData',data.time,'YData',data.position);
    case 'Velocity'
        set(h.ResultLine,'XData',data.time,'YData',data.velocity);
    case 'Acceleration'
        p1=get(h.SGorder,'UserData');
        if p1<2
            message={};
            message{end+1}='The specified fit order is too low to calculate acceleration.';
            message{end+1}='Please select a fit order >=2.';
            warndlg(message,'Fit order warning','modal');
        end
        set(h.ResultLine,'XData',data.time,'YData',data.acceleration);
end
set(h.ResultLine,'Visible','on');
ylabel(h.ResultPlot,string{value});
set(h.ResultPlot,'YLimMode','auto');

%%%%%%%%%%%%%%%%%%%%%%%
% export data to file %
%%%%%%%%%%%%%%%%%%%%%%%
function ExportData(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% generate export file name
filename=get(h.ExportFileEdit,'String');
[pathname,filename,ext]=fileparts(filename);
if isempty(filename) % help user fill empty edit box
    [filename,pathname]=uiputfile('*.*','Specify export file');    
    if isnumeric(filename)
        return
    end
    filename=fullfile(pathname,filename);
    set(h.ExportFileEdit,'String',filename);
else % use
    if isempty(pathname)
        pathname=pwd;
    end
    filename=fullfile(pathname,[filename ext]);
end
hwait=waitbar(0,'Exporting data...please wait','Name','Exporting data',...
    'WindowStyle','modal');

% access stored data, omitting nan entries
data=get(h.PlotPanel,'UserData');
%index=~isnan(data.time);
%index=~(isnan(data.time)|isnan(data.Dx));
index=~isnan(data.position);
data.time=data.time(index);
data.Dx=data.Dx(index);
data.Dy=data.Dy(index);
data.variation=data.variation(index);
data.fringe=data.fringe(index);
data.position=data.position(index);
data.velocity=data.velocity(index);
data.acceleration=data.acceleration(index);
waitbar(1/4,hwait);

% isolate date for export
choice=findall(h.ExportOptionsMenu,'Checked','on');
switch get(choice,'Tag') 
    case 'quadrature'
        tempdata=transpose([data.time(:) data.Dx(:) data.Dy(:) data.variation(:)]);
        label={'Time','Dx','Dy','Return'};
    case 'position'
        tempdata=transpose([data.time(:) data.position(:)]);
        label={'Time','Position'};
    case 'velocity'
        tempdata=transpose([data.time(:) data.velocity(:)]);
        label={'Time','Velocity'};
    case 'acceleration'
        tempdata=transpose([data.time(:) data.acceleration(:)]);
        label={'Time','Accel.'};
    case 'velocity+position'
        tempdata=transpose([data.time(:) data.velocity(:) data.position(:)]);
        label={'Time','Velocity','Position'};
    case 'full'
        tempdata=transpose(...
            [data.time(:) data.Dx(:) data.Dy(:) data.variation(:) data.velocity(:) data.position(:) data.acceleration(:)]);
        label={'Time','Dx','Dy','Return','Velocity','Position','Accel.'};
end
waitbar(2/4,hwait);

% work out appropriate formats
before=3;
gap=1;
if ispc
    after=5;
else
    after=4;
end
extra=before+after+gap;

dt=(data.time(end)-data.time(1))/(numel(data.time)-1);
NDtime=abs(floor(log10(dt/max(abs(data.time)))));
Wtime=NDtime+extra;
timeformat=sprintf('%%+%d.%de',Wtime,NDtime);

NDother=4;
Wother=NDother+extra;
otherformat=sprintf('%%+%d.%de',Wother,NDother);

% write data to export file
header{1}=sprintf('THRIVE export (%s)',datestr(now));
Ncol=numel(label);
format=[sprintf('%%%ds',Wtime) repmat(sprintf('%%%ds',Wother),[1 Ncol-1])];
header{2}=sprintf(format,label{:});
format=[timeformat repmat(otherformat,[1 Ncol-1]) '\n'];

fid=fopen(filename,'wt');
fprintf(fid,'%s\n',header{:});
fprintf(fid,format,tempdata);
fclose(fid);
if ishandle(hwait) % user let the file load
    waitbar(1,hwait);
    pause(0.25);
    delete(hwait);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% previous button callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PreviousButton(src,varargin)

fig=ancestor(src,'figure');
QuadratureScreen(fig);
set(fig,'Visible','off');