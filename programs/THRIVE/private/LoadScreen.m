% LoadScreen: 
%
function fig=LoadScreen(oldfig)

% allocate mising input
if nargin<1
    oldfig='';
end

% create figure (if necessary)
tag='THRIVE_LoadScreen';
fig=findall(0,'Type','figure','Tag',tag);
if isempty(fig)
    fig=createGUI('Tag',tag);
end

% call specific operations
if isempty(oldfig)
    return
end
switch get(oldfig,'Tag')
    case 'THRIVE_QuadratureScreen'
        % do something
    case 'THRIVE_EllipseScreen'        
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
%hsub=uimenu(hm,'Label','Restore','Visible','off');
%uimenu(hsub,'Label','Previous session','Enable','off');
%uimenu(hsub,'Label','Exported data','Enable','off');
uimenu(hm,'Label','Start over',...
    'Tag','StartOver','Callback',@StartOver);
uimenu(hm,'Label','Exit','Separator','on','Callback','close(gcbf)');

hm=uimenu(fig,'Label','Characterization','Tag','CharacterizationMenu');
uimenu(hm,'Label','None (ideal system)','Tag','ideal',...
    'Callback',@CharacterizationCallback,'Checked','off');
uimenu(hm,'Label','Ellipse fit','Tag','ellipse',...
    'Callback',@CharacterizationCallback,'Checked','on');
%uimenu(hm,'Label','Beam block','Tag','beamblock',...
%    'Callback',@CharacterizationCallback,...
%    'Enable','off');
uimenu(hm,'Label','Unroll phase','Tag','unroll','Separator','on',...
    'Callback',{@unrollPhase,fig},'Enable','off');

hm=uimenu(fig,'Label','Help');
uimenu(hm,'Label','About THRIVE','Callback',{@aboutTHRIVE,fig});
uimenu(hm,'Label','Loading data','Callback',@HelpWindow);

% create control panel
hpanel(1)=custom_uipanel('Parent',fig,'Tag','ControlPanel');
filename0=repmat('M',[1 50]);
number0=' +0.00000E+00 ';

pos(1)=data.xmargin;
pos(2)=0;
[h,pos]=radiobutton(hpanel(1),pos,'Single file',...
    'Tag','SingleFile','Value',1,'Callback',@FileNumberSelection,...
    'ToolTipString','Specify one data file: [time D1 D2 D3]');
pos(1)=pos(1)+pos(3);
[h,pos]=radiobutton(hpanel(1),pos,'Separate files',...
    'Tag','MultipleFile','Value',0,'Callback',@FileNumberSelection,...
    'ToolTipString','Specify three data files: [time signal]');
pos(1)=pos(1)+pos(3)+2*data.xmargin;
[h,pos]=pushbutton(hpanel(1),pos,' Load data ',...
    'Tag','LoadData','Callback',@LoadData);

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,'D1 file:',...
    'Tag','File1Label','HorizontalAlignment','right',...
    'String','File:');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,filename0,...
    'Tag','File1Edit','HorizontalAlignment','left',...
    'String','');
hedit=h;
pos(1)=pos(1)+pos(3);
[h,pos]=pushbutton(hpanel(1),pos,' select ',...
    'Tag','File1Select','Callback',{@SelectFile,hedit});

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,'Column order: ',...
    'Tag','ColumnOrder','HorizontalAlignment','right',...
    'ToolTipString','Convention: D2 leads D1, D3 lags D1');
pos(1)=pos(1)+pos(3);
string='(D1,D2,D3)';
[h,pos]=radiobutton(hpanel(1),pos,string,...
    'Tag','D123order','Value',1,'Callback',@ColumnOrderSelection);
pos(1)=pos(1)+pos(3);
string='(D1,D3,D2)';
[h,pos]=radiobutton(hpanel(1),pos,string,...
    'Tag','D132order','Value',0,'Callback',@ColumnOrderSelection);

pos(1)=data.xmargin;
[h,pos]=textlabel(hpanel(1),pos,'D2 file:',...
    'Tag','File2Label','HorizontalAlignment','right',...
    'Visible','off');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,filename0,...
    'Tag','File2Edit','HorizontalAlignment','left',...
    'String','','Visible','off');
hedit=h;
pos(1)=pos(1)+pos(3);
[h,pos]=pushbutton(hpanel(1),pos,' select ',...
    'Tag','File2Select','Callback',{@SelectFile,hedit},...
    'Visible','off');

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,'D3 file:',...
    'Tag','File3Label','HorizontalAlignment','right',...
    'Visible','off');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,filename0,...
    'Tag','File3Edit','HorizontalAlignment','left',...
    'String','','Visible','off');
hedit=h;
pos(1)=pos(1)+pos(3);
[h,pos]=pushbutton(hpanel(1),pos,' select ',...
    'Tag','File3Select','Callback',{@SelectFile,hedit},...
    'Visible','off');

label={'Characterization time=','Experiment time='};
[maxchar,kmax]=max(cellfun(@numel,label));
pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos(1:2),label{kmax});
set(h,'String',label{1},'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','CharacterizationTime1','Callback',@TimeEntry,...
    'String','-inf','UserData',-inf);
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,' to ');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','CharacterizationTime2','Callback',@TimeEntry,...
    'String','+inf','UserData',+inf);
pos(1)=pos(1)+pos(3);
[h,pos]=togglebutton(hpanel(1),pos,' select ',...
    'Tag','CharacterizationTimeSelect','Callback',@TimeSelect,...
    'ToolTipString','Left/right click to choose lower/upper bounds');

pos(1)=data.xmargin;
pos(2)=pos(2)-data.ygap-pos(4);
[h,pos]=textlabel(hpanel(1),pos,label{kmax});
set(h,'String',label{2},'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','ExperimentTime1','Callback',@TimeEntry,...
    'String','-inf','UserData',-inf);
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,' to ');
pos(1)=pos(1)+pos(3);
[h,pos]=editbox(hpanel(1),pos,number0,...
    'Tag','ExperimentTime2','Callback',@TimeEntry,...
    'String','+inf','UserData',+inf);
pos(1)=pos(1)+pos(3);
[h,pos]=togglebutton(hpanel(1),pos,' select ',...
    'Tag','ExperimentTimeSelect','Callback',@TimeSelect,...
    'ToolTipString','Left/right click to choose lower/upper bounds');

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
%data.Lx=panelpos(3); % overide mininum figure width set above
set(hpanel(1),'Position',panelpos,'UserData',data);

% create plot panel
hpanel(2)=custom_uipanel('Parent',fig,'Tag','PlotPanel');
set(hpanel(2),'BorderType','line');
ha=axes('Parent',hpanel(2),'Tag','SignalPlot',...
    'Units','normalized','OuterPosition',[0 0 1 1],...
    'FontUnits','points','FontSize',14,...
    'Box','on');
hl(1)=line('Parent',ha,'Tag','D1','Color',[0 0 1]);
hl(2)=line('Parent',ha,'Tag','D2','Color',[0 0.5 0]);
hl(3)=line('Parent',ha,'Tag','D3','Color',[1 0 0]);
hl(4)=line('Parent',ha,'Tag','CharacterizationBound1',...
    'Color',[0 0 0],'LineStyle','--','LineWidth',2);
hl(5)=line('Parent',ha,'Tag','CharacterizationBound2',...
    'Color',[0 0 0],'LineStyle','--','LineWidth',2);
hl(6)=line('Parent',ha,'Tag','ExperimentBound1',...
    'Color',[0 0 0],'LineStyle','-','LineWidth',2);
hl(7)=line('Parent',ha,'Tag','ExperimentBound2',...
    'Color',[0 0 0],'LineStyle','-','LineWidth',2);
set(hl,'Visible','off');
xlabel(ha,'Time');
ylabel(ha,'Signal');
title(ha,'Measured detector signals');

h=uicontrol('Parent',hpanel(2),'Tag','ClonePlot',...
    'String',' clone ','Callback',@ClonePlot,...
    'Units','pixels','ToolTipString','Clone plot to separate window');
extent=get(h,'Extent');
set(h,'Position',extent);

% create next/previous buttons
h=custom_uicontrol('Parent',fig,'Style','pushbutton',...
    'Tag','Previous','String',' < Previous ','Visible','off');
pos=get(h,'Position');
h=custom_uicontrol('Parent',fig,'Style','pushbutton',...
    'Tag','Next','String',' Next > ','Callback',@NextButton);
set(h,'Position',pos);
custom_uicontrol('Parent',fig,'Style','text',...
    'Tag','GUIlabel','String','Load data ','FontWeight','bold',...
    'BackgroundColor',get(fig,'Color'));

% final items
set(fig,'ResizeFcn',@ResizeFcn);
NudgeTextBoxes(fig);

h=guihandles(fig);
hselect=[h.File1Select h.File2Select h.File3Select];
plink=linkprop(hselect,'UserData');
data=get(h.File1Select,'UserData');
data.plink=plink;
set(h.File1Select,'UserData',data);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% characteriation menu callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CharacterizationCallback(src,varargin)

menu=get(src,'parent');
items=get(menu,'Children');
set(items,'Checked','off');
set(src,'Checked','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select single file/multiple files callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FileNumberSelection(src,varargin)

% get all handles
%h=get(src,'UserData');
fig=ancestor(src,'figure');
h=guihandles(fig);
tag=get(src,'Tag');

switch tag % hide/reveal relevant objects
    case 'SingleFile'
        if get(h.MultipleFile,'Value')==0 % no change made
            set(src,'Value',1);
            return
        end
        set(h.MultipleFile,'Value',0);
        set(h.File1Label,'String','File:');
        set(h.File1Edit,'String','');
        %callback=get(h.File1Select,'Callback');        
        %callback{3}={};
        %set(h.File1Select,'Callback',callback(:))
        %
        reveal=[h.ColumnOrder h.D123order h.D132order];
        set(reveal,'Visible','on');
        %
        hide=[h.File2Label h.File2Edit h.File2Select];
        set(hide,'Visible','off');
        %
        hide=[h.File3Label h.File3Edit h.File3Select];
        set(hide,'Visible','off');
        %
        hl=[h.D1 h.D2 h.D3];
        set(hl,'Visible','off');
    case 'MultipleFile'        
        if get(h.SingleFile,'Value')==0 % no change made
            set(src,'Value',1);
            return
        end 
        set(h.SingleFile,'Value',0);
        set(h.File1Label,'String','D1 file:');
        set(h.File1Edit,'String','');
        %callback=get(h.File1Select,'Callback');
        %callback{3}=FilterSpec;
        %set(h.File1Select,'Callback',callback(:))
        %
        hide=[h.ColumnOrder h.D123order h.D132order];
        set(hide,'Visible','off');
        %
        reveal=[h.File2Label h.File2Edit h.File2Select];
        set(reveal,'Visible','on');
        set(h.File2Edit,'String','');
        %
        reveal=[h.File3Label h.File3Edit h.File3Select];
        set(reveal,'Visible','on');
        set(h.File3Edit,'String','');
        %
        hl=[h.D1 h.D2 h.D3];
        set(hl,'Visible','off');
end

%%%%%%%%%%%%%%%%%%%%%%
% load data callback %
%%%%%%%%%%%%%%%%%%%%%%
function LoadData(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);%get(fig,'UserData');
set(h.unroll,'Enable','off');

% read file name
if logical(get(h.SingleFile,'Value')) % single file mode
    filename=get(h.File1Edit,'String');
    if isempty(filename) % try to help the user
        callback=get(h.File1Select,'Callback');
        feval(callback{1},[],[],callback{2:end});
    end
    filename=get(h.File1Edit,'String');
    if isempty(filename) % don't proceed
        msg{1}='ERROR: no input file specified!';
        msg{2}='Please select an input file before proceeding.';
        msg=sprintf('%s\n',msg{:});
        errordlg(msg,'No input file');
        return
    end
    try        
        hwait=waitbar(0,'Loading data file...please wait',...
            'Name','Loading file','WindowStyle','modal');
        [data,header,choice]=ColumnReader(filename);
        if ~ishandle(hwait) % user cancel
            return
        end
        waitbar(1,hwait);
        time=data(:,1);
        D1=data(:,2);
        if get(h.D123order,'Value')==1 % default order                    
            D2=data(:,3);
            D3=data(:,4);
        else % reverse order
            D3=data(:,3);
            D2=data(:,4);
        end
        if isempty(filename) % edit box was empty
            set(h.File1Edit,'String',choice); 
        end
    catch
        errordlg('Unable to read data file','File error');
        delete(hwait);
        return
    end
elseif logical(get(h.MultipleFile,'Value')) % multiple file mode    
    filename{1}=get(h.File1Edit,'String');    
    filename{2}=get(h.File2Edit,'String');
    filename{3}=get(h.File3Edit,'String');
    for k=1:3
        if isempty(filename{k})
            warndlg('Three data files are needed','!! Warning !!');
            return
        end
    end
    try
        hwait=waitbar(0,'Loading data files...please wait',...
            'Name','Loadingfiles','WindowStyle','modal');
        data=DataReader(filename{1});
        if ~ishandle(hwait) % user cancel
            return
        end
        waitbar(1/3,hwait);
        time=data(:,1);
        D1=data(:,2);
        data=DataReader(filename{2});
        if ~ishandle(hwait) % user cancel
            return
        end
        waitbar(2/3,hwait);
        D2=data(:,2);
        data=DataReader(filename{3});
        if ~ishandle(hwait) % user cancel
            return
        end
        waitbar(1,hwait);
        D3=data(:,2);
    catch
        warndlg('Multiple file load unsuccessful','!! Warning !!');
        delete(hwait);
        return
    end
end

set(h.D1,'Xdata',time,'YData',D1);
set(h.D2,'Xdata',time,'YData',D2);
set(h.D3,'Xdata',time,'YData',D3);
hl=[h.D1 h.D2 h.D3];
set(hl,'Visible','on');

Dmax=max([max(D1) max(D2) max(D3)]);
Dmin=min([min(D1) min(D1) min(D3)]);
set(h.CharacterizationBound1,'YData',[Dmin Dmax]);
set(h.CharacterizationBound2,'YData',[Dmin Dmax]);
set(h.ExperimentBound1,'YData',[Dmin Dmax]);
set(h.ExperimentBound2,'YData',[Dmin Dmax]);
set(h.unroll,'Enable','on');

%ha=get(h.D1,'Parent');
%legend(ha,'off');
%legend(h.SignalPlot,'off');
%[hlegend,hobject]=legend(hl,'D1','D2','D3','Location','best');
%set(hobject,'Tag',''); % remove legend tags (avoids multiple tag issues)
clean_legend(hl,'D1','D2','D3');

delete(hwait);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select file reader based on extension %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=DataReader(filename)

import SMASH.FileAccess.*

[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.dig'
        [y,x]=digread(filename);
        data=[x(:) y(:)];
    case '.isf'
        data=readFile(filename,'tektronix');
        data=[data.Time(:) data.Signal(:)];
    case '.wfm'
        [y,x]=wfmread(filename);
        if isempty(y)
            [y,x]=yokowfmread(filename);
        end
        data=[x(:) y(:)];
    case '.trc'
        data=readFile(filename,'lecroy');
        data=[data.Time(:) data.Signal(:)];
    case {'.h5' '.bin'}
        data=readFile(filename,'keysight');
        data=[data.Time(:) data.Signal(:)];
    otherwise
        data=ColumnReader(filename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% column ordering callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ColumnOrderSelection(src,varargin)

% get handles
fig=ancestor(src,'figure');
%h=get(fig,'UserData');
h=guihandles(fig);
switch get(src,'Tag')
    case 'D123order'
        other=h.D132order;
    case 'D132order'
        other=h.D123order;
end

% see if change was made
if get(other,'Value')==0 
    set(src,'Value',1); % turn selection back on
    return
end

% apply change
set(other,'Value',0);
xtemp=get(h.D2,'XData');
ytemp=get(h.D2,'YData');
set(h.D2,'XData',get(h.D3,'XData'));
set(h.D2,'YData',get(h.D3,'YData'));
set(h.D3,'XData',xtemp);
set(h.D3,'YData',ytemp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time entry callback (experiment and characterization)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TimeEntry(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% read entry
data=ReadEditBox(src);

% determine proper bounding line handle
switch get(src,'Tag')
    case 'CharacterizationTime1'
        hline=h.CharacterizationBound1;
    case 'CharacterizationTime2'
        hline=h.CharacterizationBound2;
    case 'ExperimentTime1'
        hline=h.ExperimentBound1;
    case 'ExperimentTime2'
        hline=h.ExperimentBound2;
end

% update bounding line
if isfinite(data)
    data=repmat(data,[1 2]);
    set(hline,'XData',data,'Visible','on');
else
    set(hline,'Visible','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time select callback (experiment and characterization) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TimeSelect(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);
data=get(src,'UserData');
haxes=h.SignalPlot;

child=get(haxes,'Children');
switch get(src,'Tag')
    case 'CharacterizationTimeSelect'
        hedit(1)=h.CharacterizationTime1;
        hedit(2)=h.CharacterizationTime2;
        off=h.ExperimentTimeSelect;
    case 'ExperimentTimeSelect'
        hedit(1)=h.ExperimentTime1;
        hedit(2)=h.ExperimentTime2;
        off=h.CharacterizationTimeSelect;        
end

% toggle actions
if get(src,'Value')==1 % toggle activated
    set(off,'Value',0);
    TimeSelect(off); % turn other toggle off
    data.pointer=get(fig,'Pointer');
    data.AxesButtonDownFcn=get(haxes,'ButtonDownFcn');
    data.ChildButtonDownFcn=get(child,'ButtonDownFcn');
    set(fig,'Pointer','crosshair');
    set(haxes,'ButtonDownFcn',{@TimeSelectButtonDown,hedit});
    set(child,'ButtonDownFcn',{@TimeSelectButtonDown,hedit});
    % suspend figure toolbar toggle
    toggle=findall(h.MinimalFigureToolbar,'Type','uitoggletool','State','on');
    if isempty(toggle)
        data.ActiveToggle=[];
    else
        set(toggle,'State','off');
        data.ActiveToggle=toggle;
        for k=1:numel(toggle)
            callback=get(toggle(k),'ClickedCallback');
            if iscell(callback)
                feval(callback{1},toggle(k),[],callback{2:end});
            else
                feval(callback,toggle(k),[]);
            end
        end
    end
    set(src,'UserData',data);
else % toggle deactivated
    if isfield(data,'pointer')
        % restore pointer and button down functions
        set(fig,'Pointer',data.pointer);
        set(haxes,'ButtonDownFcn',data.AxesButtonDownFcn);
        for ii=1:numel(child)
            set(child(ii),'ButtonDownFcn',data.ChildButtonDownFcn{ii});
        end
        % restore figure toolbar toggle
        if ishandle(data.ActiveToggle)
            toggle=data.ActiveToggle;
            set(toggle,'State','on');
            for k=1:numel(toggle)
                callback=get(toggle(k),'ClickedCallback');
                if iscell(callback)
                    feval(callback{1},toggle(k),[],callback{2:end});
                else
                    feval(callback,toggle(k),[]);
                end
            end
        end                        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time select button down callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TimeSelectButtonDown(src,eventdata,hedit)

% determine selection type
fig=ancestor(src,'figure');
switch lower(get(fig,'SelectionType'))
    case 'normal' % left click
        ii=1;
    case {'extend','alt'} % right click or modified left click
        ii=2;        
    otherwise
        return
end

% if source object is a line, find its parent axes
type=get(src,'Type');
if strcmp(type,'line')
    src=ancestor(src,'axes');
end

% determine current axes point
data=get(src,'CurrentPoint');
data=num2str(data(1,1)); 

% update edit box
set(hedit(ii),'String',data);
TimeEntry(hedit(ii));

%%%%%%%%%%%%%%%%%%%%%%%%
% next button callback %
%%%%%%%%%%%%%%%%%%%%%%%%
function NextButton(src,varargin)

% get handles
fig=ancestor(src,'figure');
h=guihandles(fig);

% make sure data has been loaded
D1flag=strcmp(get(h.D1,'Visible'),'on');
D2flag=strcmp(get(h.D2,'Visible'),'on');
D3flag=strcmp(get(h.D3,'Visible'),'on');
if ~D1flag || ~D2flag || ~D3flag
    msg{1}='ERROR: no data loaded!';
    msg{2}='Please load signal data before proceeding.';
    msg=sprintf('%s\n',msg{:});
    errordlg(msg,'No data');
    return
end

% proceed to next screen
choice=findall(h.CharacterizationMenu,'Checked','on');
switch get(choice,'Tag')
    case 'ideal'
        QuadratureScreen(fig);
    case 'ellipse'
        EllipseScreen(fig);
    case 'beamblock'
        %BeamBlockScreen(fig);
end
set(fig,'Visible','off');