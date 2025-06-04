
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TimeShiftDialog(data)

mainfig=findall(0,'Type','figure','Tag','PointVISAR');
maindata=get(mainfig,'UserData');

% create dialog (if necessary)
dlg=findall(0,'Type','figure','Tag','PointVISAR:TimeShift');
if ishandle(dlg)
    figure(dlg);
    select=findobj(dlg,'Tag','RecordSelect');
else
    [dlg,select]=CreateDialog;
end

% store necessary information and update list selection
for ii=1:numel(data)
    DialogData{ii}.TimeShift=data{ii}.TimeShift;
    DialogData{ii}.OldTimeShift=data{ii}.TimeShift;
    DialogData{ii}.OldAddJumps=data{ii}.AddJumps;
    DialogData{ii}.OldSubtractJumps=data{ii}.SubtractJumps;
    label{ii}=['Record #' num2str(ii,'%d') ':  ' data{ii}.Label];
end
set(select,'String',label,'Value',ActiveRecord(maindata));
set(dlg,'UserData',DialogData);

UpdateDialog;

%%%%%%%%%%%%%%%%
% subfunctions %
%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fig,select]=CreateDialog()

% spacing parameters (characters)
dx=5;
dy=1;
ControlHeight=2;
TextWidth=20;
TextHeight=1.5;

FigWidth=2*TextWidth+3*dx;
FigHeight=TextHeight+2*ControlHeight+4*dy;

fig=figure('Visible','off',...
    'MenuBar','none','Toolbar','none',...
    'Tag','PointVISAR:TimeShift','Resize','off',...
    'NumberTitle','off','Name','Time Shifting',...
    'Units','characters','Position',[0 0 FigWidth FigHeight],...
    'CloseRequestFcn',@ExitDialog);
movegui(fig,'center');
figure(fig);
figpos=get(fig,'Position');

% record selection popup
x0=dx;
y0=figpos(4)-dy-ControlHeight;
width=figpos(3)-2*dx;
height=ControlHeight;
select=uicontrol('Style','popup',...
    'Tag','RecordSelect','String',' ',...
    'Callback',@RecordSelectCallback,...
    'Units','characters','Position',[x0 y0 width height]);

% create text label and edit box
x0=dx;
y0=figpos(4)-dy-ControlHeight-dy-TextHeight;
htext=uicontrol('Style','text',...
    'Tag','TimeShiftLabel','String','Time shift=',...
    'HorizontalAlignment','right',...
    'BackgroundColor',get(fig,'Color'),...
    'Units','characters','Position',[x0 y0 TextWidth TextHeight]);

x0=x0+TextWidth;
hedit=uicontrol('Style','edit',...
    'Interruptible','off',...
    'Tag','TimeShiftEditBox','String','',...
    'BackgroundColor',[1 1 1],...
    'Callback',@TimeShiftEdit,...
    'Units','characters','Position',[x0 y0 TextWidth TextHeight]);

% ok/cancel buttons at the bottom
y0=dy; 
cancel=uicontrol('Style','pushbutton',...
    'String','Cancel','Tag','cancel','Units','characters'); 
extent=get(cancel,'Extent');
width=1.25*extent(3);
x0=figpos(3)-dx-width;
set(cancel,'Position',[x0 y0 width ControlHeight]);

ok=uicontrol('Style','pushbutton',...
    'String','OK','Tag','ok','Units','characters'); 
x0=x0-dx/2-width;
set(ok,'Position',[x0 y0 width ControlHeight]);
set([ok cancel],'Callback',@ExitDialog);

children=[select htext hedit ok cancel];
set(fig,'Children',children(end:-1:1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ShiftData,selection]=CurrentShiftData(src)

ShiftData=get(src,'UserData');
h=findobj(src,'Tag','RecordSelect');
selection=get(h,'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateDialog()

% extract current shift
dlg=findall(0,'Type','figure','Tag','PointVISAR:TimeShift');
[ShiftData,selection]=CurrentShiftData(dlg);
ShiftData=ShiftData{selection};

hedit=findobj(dlg,'Tag','TimeShiftEditBox');
set(hedit,'String',num2str(ShiftData.TimeShift));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateMainGUI()

dlg=findall(0,'type','figure','Tag','PointVISAR:TimeShift');
DialogData=get(dlg,'UserData');
main=findall(0,'type','figure','Tag','PointVISAR');
data=get(main,'UserData');

popup=findobj(dlg,'Tag','RecordSelect');
current=get(popup,'Value');

% update all time quantities and redo analysis
data{current}.InitialTime=data{current}.InitialTime...
    -data{current}.TimeShift+DialogData{current}.TimeShift;
data{current}.ExperimentTime=data{current}.ExperimentTime...
    -data{current}.TimeShift+DialogData{current}.TimeShift;
data{current}.AddJumps=data{current}.AddJumps...
    -data{current}.TimeShift+DialogData{current}.TimeShift;
data{current}.SubtractJumps=data{current}.SubtractJumps...
    -data{current}.TimeShift+DialogData{current}.TimeShift;
data{current}.TimeShift=DialogData{current}.TimeShift;
data{current}=VisarAnalysis(data{current},'PreProcessing','Velocity');

PointVISARGUI(data);
figure(dlg);

%%%%%%%%%%%%%
% callbacks %
%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TimeShiftEdit(src,varargin)

dlg=ancestor(src,'figure');
[ShiftData,selection]=CurrentShiftData(dlg);

value=get(src,'String');
%value=str2num(value);
value=str2double(value);
if isempty(value)
    value=ShiftData{selection}.TimeShift;
    set(src,'String',num2str(value,'%g'));
    message{1}='Invalid numeric input given';
    message{2}='Previous value retained';
    warndlg(message,'Invalid input');
else
    ShiftData{selection}.TimeShift=value;
    set(dlg,'UserData',ShiftData);
end

UpdateMainGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExitDialog(src,varargin)

fig=ancestor(src,'figure');
main=findall(0,'Type','figure','Tag','PointVISAR');
choice=get(src,'Tag');
if strcmp(choice,'ok') % user chose Ok button
    delete(fig);
    figure(main);
    return
end

% see if the user is serious about cancel
prompt{1}='All time shift changes be lost! Continue?';
answer=questdlg(prompt,'Cancel time shifts');
if strcmpi(answer,'yes')
    DialogData=get(fig,'UserData');
    data=get(main,'UserData');
    for ii=1:numel(data)
        data{ii}.AddJumps=DialogData{ii}.OldAddJumps;
        data{ii}.SubtractJumps=DialogData{ii}.OldSubtractJumps;
        data{ii}.TimeShift=DialogData{ii}.OldTimeShift;
        data{ii}=VisarAnalysis(data{ii},'PreProcessing','Velocity');       
    end
    PointVISARGUI(data);
    delete(fig);
else
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecordSelectCallback(varargin)

UpdateDialog;