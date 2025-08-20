% datadlg: create a data dialog box
%
% 
function answer=datadlg_calhist(name,label,default,options)

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

popupstring = {'maximum','centroid','parabola','gaussian','robust'};
switch default{4};
    case popupstring{1}
        popupval=1;
    case popupstring{2}
        popupval=2;
    case popupstring{3}
        popupval=3;
    case popupstring{4}
        popupval=4;
    case popupstring{5}
        popupval=5;
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

set(fig,'Position',[0 0 35 20],'Visible','off');
movedlg(fig,options.root,options.location);
set(fig,'Visible','on');


edittext(1) = uicontrol('Style','text','String',label{1},...
        'Units','characters','Position',[5 18 25 1.2],...
        'BackgroundColor',textbg,'HorizontalAlignment','left');
editbox(1) = uicontrol('Style','edit','String',edit{1},...
        'Units','characters','Position',[5 16 25 2],...
        'BackgroundColor','w','HorizontalAlignment','left');

edittext(2) = uicontrol('Style','text','String',label{2},...
        'Units','characters','Position',[5 14 25 1.2],...
        'BackgroundColor',textbg,'HorizontalAlignment','left');
editbox(2) = uicontrol('Style','edit','String',edit{2},...
        'Units','characters','Position',[5 12 25 2],...
        'BackgroundColor','w','HorizontalAlignment','left');

edittext(3) = uicontrol('Style','text','String',label{3},...
        'Units','characters','Position',[5 10 25 1.2],...
        'BackgroundColor',textbg,'HorizontalAlignment','left');
editbox(3) = uicontrol('Style','edit','String',edit{3},...
        'Units','characters','Position',[5 8 25 2],...
        'BackgroundColor','w','HorizontalAlignment','left');

popuptext = uicontrol('Style','Text','String',label{4},...
    'Units','characters','HorizontalAlignment','left',...
    'BackgroundColor',textbg,'Position',[5 6 25 1.2]);
popupbox = uicontrol('style','popupmenu',...
    'Units','characters',...
    'position',[5 4.5 25 1.2],...
    'string',popupstring,...
    'backgroundcolor','w',...
    'value',popupval, ...
    'tag','listbox',...
    'callback', {@doPopupClick1,edit{4},popupstring});



pushbutton(1) = uicontrol('Style','pushbutton','String','OK',...
        'Units','characters','Position',[5 1 10 2],...
        'Callback',@callbackOK);
pushbutton(2) = uicontrol('Style','pushbutton','String','Cancel',...
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

function doPopupClick1(src,eventdata,oldval,popupstring)

fig=gcbf;
data=get(fig,'UserData');
nold = oldval;
n = get(src,'Value');
if n == 0
    n = nold;
end
set(src,'Value',n);
data.edit{4}=popupstring{n};

set(fig,'UserData',data);



%%%%%%%%%%%%%%%%%%%%%
% default callbacks %
%%%%%%%%%%%%%%%%%%%%%
function callbackOK(varargin)
fig=gcbf;
data=get(fig,'UserData');
uiresume(fig);
data.edit{1}=get(data.editbox(1),'String');
data.edit{2}=get(data.editbox(2),'String');
data.edit{3}=get(data.editbox(3),'String');
data.current=data.edit;
set(fig,'UserData',data);

function callbackCancel(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current={};
set(fig,'UserData',data);
