% Displays a modal dialog where the user can modify fringes.
% FringeDlg returns RecordData with the modified fringes.
% The dialog will display two lists, one for Add Fringes, and one for
% Subtract Fringes.  The user can click on buttons to create new fringes or
% remove fringes.
% The defaultValue that is passed in will be used as the default value when
% the user creates a new fringe.

% created 1/6/2005 by Ed Kaltenbach (ARA)
% edited 7/1/2005 by Daniel Dolan (Sandia)
% updated 2/15/2007 by Daniel Dolan

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FringeDialog(data)

fig=findall(0,'Tag','PointVISAR:Fringes');
if ishandle(fig) % active GUI if present
    figure(fig);
    select=findobj(fig,'Tag','RecordSelect');
else % create the GUI
    % spacing parameters (characters)
    dx=5;
    dy=1;
    ControlHeight=2;
    PanelWidth=30;
    PanelHeight=25;
    ButtonWidth=10;
    ButtonHeight=2;
    FigWidth=2*PanelWidth+3*dx;
    FigHeight=PanelHeight+2*ControlHeight+4*dy;
    % create figure
    fig=figure('Visible','off',...
        'MenuBar','none','Toolbar','none',...
        'Tag','PointVISAR:Fringes','Resize','off',...
        'NumberTitle','off','Name','Add/remove fringes',...
        'Units','characters','Position',[0 0 FigWidth FigHeight],...
        'CloseRequestFcn',@ExitDialog);
    movegui(fig,'center');
    figure(fig);
    figpos=get(fig,'Position');
    % create record selection popup
    x0=dx;
    y0=figpos(4)-dy-ControlHeight;
    width=figpos(3)-2*dx;
    height=ControlHeight;
    select=uicontrol('Style','popup',...
        'Tag','RecordSelect','String',' ',...
        'FontName','fixed',...
        'Callback',@RecordSelectCallback,...
        'Units','characters','Position',[x0 y0 width height]);
    % create add fringe panel
    x0=dx;
    y0=figpos(4)-dy-ControlHeight-dy-PanelHeight;
    addPanel=uipanel('Title','Add Fringes','Tag','AddPanel',...
        'Units','characters','Position', [x0 y0 PanelWidth PanelHeight]);
    AddButton(1)=uicontrol('Parent',addPanel,'Style','pushbutton',...
        'Tag','AddDelete','String','Delete',...
        'FontName','fixed',...
        'Units','characters','Callback',@DeleteBtnCallback);
    extent=get(AddButton(1),'Extent');
    width=1.25*extent(3);
    gap=(PanelWidth-3*width)/4;
    x0=PanelWidth-gap-width;
    y0=dy;
    height=ControlHeight;
    set(AddButton(1),'Position',[x0 y0 width height]);
    AddButton(2)=uicontrol('Parent',addPanel,'Style','pushbutton',...
        'Tag','AddEdit','String','Edit',...
        'FontName','fixed',...
        'Units','characters','Callback',@EditBtnCallback);
    x0=x0-gap-width;
    set(AddButton(2),'Position',[x0 y0 width height]);
    AddButton(3)=uicontrol('Parent',addPanel,'Style','pushbutton',...
        'Tag','AddNew','String','New',...
        'Units','characters','Callback',@NewBtnCallback);
    x0=x0-gap-width;
    set(AddButton(3),'Position',[x0 y0 width height]);
    x0=2;
    y0=y0+ControlHeight+dy;
    width=PanelWidth-2*x0;
    height=PanelHeight-y0-2*dy;
    addList = uicontrol('Parent',addPanel,...
        'Style','listbox','Tag','AddList',...
        'Max',0,'Min',1,'BackgroundColor', [1 1 1],...
        'FontName','fixed',...
        'Units','characters','Position',[x0 y0 width height]);
    children=[addList AddButton(end:-1:1)];
    set(addPanel,'Children',children(end:-1:1));
    % create subtract fringe panel
    x0=dx+PanelWidth+dx;
    y0=figpos(4)-dy-ControlHeight-dy-PanelHeight;
    subtractPanel=uipanel('Title','Subtract Fringes','Tag','SubtractPanel',...
        'Units','characters','Position', [x0 y0 PanelWidth PanelHeight]);

    SubtractButton(1)=uicontrol('Parent',subtractPanel,'Style','pushbutton',...
        'Tag','SubtractDelete','String','Delete',...
        'Units','characters','Callback',@DeleteBtnCallback);
    extent=get(SubtractButton(1),'Extent');
    width=1.25*extent(3);
    gap=(PanelWidth-3*width)/4;
    x0=PanelWidth-gap-width;
    y0=dy;
    height=ControlHeight;
    set(SubtractButton(1),'Position',[x0 y0 width height]);

    SubtractButton(2)=uicontrol('Parent',subtractPanel,'Style','pushbutton',...
        'Tag','SubtractEdit','String','Edit',...
        'Units','characters','Callback',@EditBtnCallback);
    x0=x0-gap-width;
    set(SubtractButton(2),'Position',[x0 y0 width height]);

    SubtractButton(3)=uicontrol('Parent',subtractPanel,'Style','pushbutton',...
        'Tag','SubtractNew','String','New',...
        'Units','characters','Callback',@NewBtnCallback);
    x0=x0-gap-width;
    set(SubtractButton(3),'Position',[x0 y0 width height]);

    x0=2;
    y0=y0+ControlHeight+dy;
    width=PanelWidth-2*x0;
    height=PanelHeight-y0-2*dy;
    subtractList = uicontrol('Parent',subtractPanel,...
        'Style','listbox','Tag','SubtractList',...
        'Max',0,'Min',1,'BackgroundColor', [1 1 1],...
        'Units','characters','Position',[x0 y0 width height]);

    children=[subtractList SubtractButton(end:-1:1)];
    set(subtractPanel,'Children',children(end:-1:1));

    % fringe width button
    x0=dx;
    y0=dy;
    setwidth=uicontrol('Style','pushbutton',...
        'String','Set width','Tag','width','Units','characters');
    extent=get(setwidth,'Extent');
    width=1.25*extent(3);
    set(setwidth,'Position',[x0 y0 width ControlHeight]);
    set(setwidth,'Callback',@SetFringeWidth);

    % ok/cancel buttons at the bottom
    y0=dy;
    cancel=uicontrol('Style','pushbutton',...
        'String','Cancel','Tag','cancel','Units','characters');
    extent=get(cancel,'Extent');
    width=1.25*extent(3);
    x0=figpos(3)-dx-width;
    set(cancel,'Position',[x0 y0 width ControlHeight]);

    ok=uicontrol('Style','pushbutton',...
        'String','Ok','Tag','ok','Units','characters');
    x0=x0-dx/2-width;
    set(ok,'Position',[x0 y0 width ControlHeight]);
    set([ok cancel],'Callback',@ExitDialog);

    children=[select addPanel subtractPanel setwidth ok cancel];
    set(fig,'Children',children(end:-1:1));
    
end

% store needed info and update dialog
for ii=1:numel(data)
    DialogData{ii}.AddJumps=data{ii}.AddJumps;
    DialogData{ii}.OldAddJumps=data{ii}.AddJumps;
    DialogData{ii}.SubtractJumps=data{ii}.SubtractJumps;
    DialogData{ii}.OldSubtractJumps=data{ii}.SubtractJumps;
    DialogData{ii}.JumpWidth=data{ii}.JumpWidth;
    label{ii}=['Record #' num2str(ii,'%d') ':  ' data{ii}.Label];
end
set(select,'String',label,'Value',ActiveRecord(data));
set(fig,'UserData',DialogData,'HandleVisibility','callback');

UpdateDialog;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [jumps,selection]=CurrentJumps(src)

%mainfig=findall(0,'Type','figure','Tag','PointVISAR:Fringes');
jumps=get(src,'UserData');
h=findobj(src,'Tag','RecordSelect');
selection=get(h,'Value');
     
%%%%%%%%%%%%%%%%%%%%%%%
function UpdateDialog()

dlg=findall(0,'Type','figure','Tag','PointVISAR:Fringes');

% extract jumps for the selected record
[jumps,selection]=CurrentJumps(dlg);
jumps=jumps{selection};

% display add jumps
addUiList = findobj(dlg, 'Tag', 'AddList');
label={};
add=jumps.AddJumps;
for ii=1:numel(add)
    label{ii}=num2str(add(ii));
end
set(addUiList,'String',label);

% display subtract jumps
subUiList = findobj(dlg, 'Tag', 'SubtractList');
label={};
subtract=jumps.SubtractJumps;
for ii=1:numel(subtract)
    label{ii}=num2str(subtract(ii));
end
set(subUiList,'String',label);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateMainGUI()

dlg=findall(0,'Type','figure','Tag','PointVISAR:Fringes');
DialogData=get(dlg,'UserData');
main=findall(0,'Type','figure','Tag','PointVISAR');
data=get(main,'UserData');

popup=findobj(dlg,'Tag','RecordSelect');
current=get(popup,'Value');

data{current}.AddJumps=DialogData{current}.AddJumps;
data{current}.SubtractJumps=DialogData{current}.SubtractJumps;
data{current}.JumpWidth=DialogData{current}.JumpWidth;
data{current}=VisarAnalysis(data{current},'QuadratureSignals','Velocity');

PointVISARGUI(data);
figure(dlg);

%%%%%%%%%%%%%
% callbacks %
%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewBtnCallback(src,varargin)

dlg=ancestor(src,'figure');
mode=get(src,'Tag');
switch mode
    case 'AddNew'
        prompt{1}='Enter fringe addition time: ';
        prompt{2}='Number of fringes to add: ';
        default={[] 1};
        uiList=findobj(dlg,'Tag','AddList');
        field='AddJumps';
    case 'SubtractNew'
        prompt{1}='Enter fringe subtraction time: ';
        prompt{2}='Number of fringes to subtract: ';
        default={[] 1};
        prompt{1}='Enter new subraction fringe';
        uiList=findobj(dlg,'Tag','SubtractList');
        field='SubtractJumps';
end
answer=DoubleInputDlg(prompt,'New Fringe',default);
newTime=answer{1};  
numFringe=floor(answer{2});
if numFringe<1
    numFringe=1;
end
%newTime=repmat(newTime,[1 numFringe]);

% check if user clicked "cancel"
if isempty(newTime)
    return
end
    
% add time(s) to list and sort
[jumps,selection]=CurrentJumps(dlg);
temp=jumps{selection}.(field);
for ii=1:numFringe
    temp(end+1)=newTime;
end
%temp=[temp newTime];
temp=sort(temp);
jumps{selection}.(field)=temp;

set(dlg,'UserData',jumps);

UpdateDialog;
UpdateMainGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EditBtnCallback(src,varargin)

dlg=ancestor(src,'figure');
mode=get(src,'Tag');
switch mode
    case 'AddEdit'
        prompt{1}='Edit addition fringe';
        uiList=findobj(dlg,'Tag','AddList');
        field='AddJumps';
    case 'SubtractEdit'
        prompt{1}='Edit subtraction fringe';
        uiList=findobj(dlg,'Tag','SubtractList');
        field='SubtractJumps';
end

target=get(uiList,'Value');
[jumps,selection]=CurrentJumps(dlg);
temp=jumps{selection}.(field);
if isempty(temp)
    return
end
value=temp(target);

newTime=DoubleInputDlg(prompt,'Edit Fringe',value);    
if isempty(newTime) % see if user choose cancel
    return
end
    
% update jump list and sort
temp(target)=newTime;
temp=sort(temp);
jumps{selection}.(field)=temp;

set(dlg,'UserData',jumps);
UpdateDialog;

% update fringe display for the user's benefit
UpdateMainGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DeleteBtnCallback(src,varargin)

dlg=ancestor(src,'figure');
mode=get(src,'Tag');
switch mode
    case 'AddDelete'
        uiList=findobj(dlg,'Tag','AddList');
        field='AddJumps';
        verb=' added ';
    case 'SubtractDelete'
        uiList=findobj(dlg,'Tag','SubtractList');
        field='SubtractJumps';
        verb=' subtracted ';
end

target=get(uiList,'Value');
[jumps,selection]=CurrentJumps(dlg);
temp=jumps{selection}.(field);
if isempty(temp)
    return
end
value=temp(target);

% make sure user wants to delete the fringe
prompt{1}=['Delete the fringe' verb 'at t=' num2str(value) '?'];
answer=questdlg(prompt,'Delete fringe?');
%if strcmp(lower(answer),'yes') % delete the fringe
if strcmpi(answer,'yes') % delete the fringe
    temp(target)=[];
    jumps{selection}.(field)=temp;
else
    return
end

set(uiList,'Value',1);
set(dlg,'UserData',jumps);
UpdateDialog;

% update fringe display for the user's benefit
UpdateMainGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetFringeWidth(src,varargin)

dlg=ancestor(src,'figure');
selection=get(findobj(dlg,'Tag','RecordSelect'),'Value');
data=get(dlg,'UserData');

OldWidth=data{selection}.JumpWidth;
NewWidth=DoubleInputDlg('Enter the fringe width (10-90%):','Fringe Width',OldWidth);    
if isempty(NewWidth) % see if user choose cancel
    return
end

% update record
data{selection}.JumpWidth=NewWidth;
set(dlg,'UserData',data);
UpdateMainGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExitDialog(src,varargin)

dlg=ancestor(src,'figure');
main=findall(0,'Type','figure','Tag','PointVISAR');
choice=get(src,'Tag');
if strcmp(choice,'ok') % user chose Ok button
    delete(dlg);
    figure(main);
    return
end

% see if the user is serious about cancel
prompt{1}='All fringe alterations will be lost! Continue?';
answer=questdlg(prompt,'Cancel fringes');
if strcmpi(answer,'yes')
    DialogData=get(dlg,'UserData');
    data=get(main,'UserData');
    for ii=1:numel(data)
        data{ii}.AddJumps=DialogData{ii}.OldAddJumps;
        data{ii}.SubtractJumps=DialogData{ii}.OldSubtractJumps;
        data{ii}=VisarAnalysis(data{ii},'QuadratureSignals','Velocity');
        PointVISARGUI(data);
    end
    delete(dlg);
else
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecordSelectCallback(src,eventdata)

UpdateDialog;