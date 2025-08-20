% datadlg: create a data dialog box
%
% 
function answer=datadlg_display(name,label,default,options)

% handle input
if (nargin<1) || isempty(name)
    name='Data Dialog';
end

if (nargin<2) || isempty(label)
    label={'Parameter:'};
end

if (nargin<3) || isempty(default)
    default={''};
end

if (nargin<4) || isempty(options)
    options=struct();
end
field='style';
if ~isfield(options,field) || isempty(options.(field))
    options.(field)='modal';
end
field='minwidth';
if ~isfield(options,field) || isempty(options.(field))
    options.(field)=20; % characters
end
field='root';
if ~isfield(options,field) || isempty(options.(field))
    options.(field)=0; % root object (the screen)
end
field='location';
if ~isfield(options,field) || isempty(options.(field))
    options.(field)='center'; 
end
field='fontname';
if ~isfield(options,field) || isempty(options.(field))
    options.(field)=get(0,'DefaultUIcontrolFontName'); 
end
field='fontsize';
if ~isfield(options,field) || isempty(options.(field))
    options.(field)=get(0,'DefaultUIcontrolFontSize');
end

popupstring1={'linear','log'};
switch default{1};
    case popupstring1{1}
        popupval1=1;
    case popupstring1{2}
        popupval1=2;
end
popupstring2={'jet','gray','rainbow','red','green','blue','cool','hot',...
    'spring','summer','autumn','winter',...
    'bone','copper','pink'};
for k=1:numel(popupstring2)
    if strcmp(default{3},popupstring2{k})
        popupval2=k;
    end
end

popupstring3 = {'yes','no'};
if ischar(default{4})
    if strcmpi(default{4},'yes')
        popupval3=1;
    else
        popupval3=2;
    end
elseif default{4}
    popupval3=1;
else
    popupval3=2;
end

edit{1}=default{1};
edit{2}=default{2};
edit{3}=default{3};
edit{4}=default{4};
data.edit=edit;

% create and size dialog
fig=figure('NumberTitle','off','Name',name,...
    'Menubar','none','Toolbar','none',...
    'Resize','off','Units','characters',...
    'ToolBar','none','MenuBar','none',...
    'IntegerHandle','off','Visible','on');
hgap=1.00; % horizontal gap [characters]
vgap=0.50; % vertical gap [characters]
textbg=get(fig,'Color');

%set(fig,'Position',[0 0 32 18],'Visible','off');
set(fig,'Position',[0 0 32 21.5],'Visible','off');
movedlg(fig,options.root,options.location);
set(fig,'Visible','on');

edittext = uicontrol('Style','text','String',label{2},...
        'Units','characters','Position',[5 19 25 1.2],...
        'BackgroundColor',textbg,'HorizontalAlignment','left');
editbox = uicontrol('Style','edit','String',edit{2},...
        'Units','characters','Position',[5 17 18 2],...
        'BackgroundColor','w','HorizontalAlignment','left');

popuptext1 = uicontrol('Style','Text','String',label{1},...
    'Units','characters','HorizontalAlignment','left',...
    'BackgroundColor',textbg,'Position',[5 15.5 15 1.2]);
popupstring1 = {'linear','log'};
popupbox1 = uicontrol('style','popupmenu',...
    'Units','characters',...
    'position',[5 13.5 20 1.2],...
    'string',popupstring1,...
    'backgroundcolor','w',...
    'value',popupval1, ...
    'tag','listbox',...
    'callback', {@doPopupClick,1,popupval1,popupstring1});

popuptext2 = uicontrol('Style','Text','String',label{3},'Units','characters',...
    'Units','characters','HorizontalAlignment','left',...
    'BackgroundColor',textbg,'Position',[5 11 15 1.2]);
%popupstring2 = {'jet','gray','inverse_gray','cool','hot'};
popupbox2 = uicontrol('style','popupmenu',...
    'Units','characters',...
    'position',[5 9.5 20 1.2],...
    'string',popupstring2,...
    'backgroundcolor','w',...
    'value',popupval2, ...
    'tag','listbox',...
    'callback', {@doPopupClick,3,popupval2,popupstring2});

popuptext3 = uicontrol('Style','Text','String',label{4},'Units','characters',...
    'Units','characters','HorizontalAlignment','left',...
    'BackgroundColor',textbg,'Position',[5 7 15 1.2]);
%popupval3={'yes','no'};
popupbox3 = uicontrol('style','popupmenu',...
    'Units','characters',...
    'position',[5 5.5 20 1.2],...
    'string',popupstring3,...
    'backgroundcolor','w',...
    'value',popupval3, ...
    'tag','listbox',...
    'callback', {@doPopupClick,4,popupval3,popupstring3});

pushbutton1 = uicontrol('Style','pushbutton','String','OK',...
        'Units','characters','Position',[5 1 10 2],...
        'Callback',@callbackOK);
pushbutton2 = uicontrol('Style','pushbutton','String','Cancel',...
        'Units','characters','Position',[15 1 10 2],...
        'Callback',@callbackCancel);

% store data in figure
data.editbox=editbox;
data.previous=default;
data.current=default;
set(fig,'UserData',data);

% finish up and wait for user input
set(fig,'Visible','on','HandleVisibility','Callback');
if strcmp(options.style,'modal')
    set(fig,'WindowStyle',options.style);
end
uiwait(fig);
if ishandle(fig)
    data=get(fig,'UserData');
    answer=data.current;
    delete(fig);
else
    answer={};
end


%%%%%%%%%%%%%%%%%%%%%
% utility functions %
%%%%%%%%%%%%%%%%%%%%%
function movedlg(dlg,target,location)

if (nargin<1) || isempty(location)
    location='center';
end

% determine absolute figure position
units=get(target,'Units');
set(target,'Units','pixels');
if target==0
   targetpos=get(target,'MonitorPositions');
   targetpos=targetpos(1,:);
else
    targetpos=get(target,'Position');
end
set(target,'Units',units);

% position dialog relative to figure
units=get(dlg,'Units') ;
set(dlg,'Units','pixels');
dlgpos=get(dlg,'Position');
x=targetpos(1)+(targetpos(3)-dlgpos(3))*[0 1/2 1];
y=targetpos(2)+(targetpos(4)-dlgpos(4))*[0 1/2 1];
switch lower(location)
    case 'north'
        dlgpos(1:2)=[x(2) y(3)];
    case 'south'
        dlgpos(1:2)=[x(2) y(1)];
    case 'east'
        dlgpos(1:2)=[x(1) y(2)];
    case 'west'
        dlgpos(1:2)=[x(3) y(2)];
    case 'northeast'
        dlgpos(1:2)=[x(3) y(3)];
    case 'northwest'
        dlgpos(1:2)=[x(1) y(3)];
    case 'southeast'
        dlgpos(1:2)=[x(3) y(1)];
    case 'southwest'
        dlgpos(1:2)=[x(1) y(1)];
    case 'center'
        dlgpos(1:2)=[x(2) y(2)];
    otherwise 
        error('ERROR: %s is not a valid location',location);
end
set(dlg,'Position',dlgpos);
set(dlg,'Units',units);

function doPopupClick(src,eventdata,popupnum,oldval,popupstring)

fig=gcbf;
data=get(fig,'UserData');
nold = oldval;
n = get(src,'Value');
if n == 0
    n = nold;
end
set(src,'Value',n);
data.edit{popupnum}=popupstring{n};

set(fig,'UserData',data);



%%%%%%%%%%%%%%%%%%%%%
% default callbacks %
%%%%%%%%%%%%%%%%%%%%%
function callbackOK(src,varargin)
fig=gcbf;
data=get(fig,'UserData');
uiresume(fig);
data.edit{2}=get(data.editbox,'String');
data.current=data.edit;
set(fig,'UserData',data);

function callbackCancel(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current={};
set(fig,'UserData',data);
