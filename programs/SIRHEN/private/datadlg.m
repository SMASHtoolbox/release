% datadlg: create a data dialog box
%
% This function is provides a flexible dialog box for data entry, similar
% to inputdlg.  
% Usage:
%  >> answer=datadlg(name,label,default,button,options);
%
% Cell arrays passed to the datadlg create edit boxes for user input.
% Example:
%  >> label={'Parameter 1:','Parameter 2:'};
%  >> default={'1','2'};
%  >> answer=datadlg('Set parameters',label,default);
%
% Unlike inputdlg, customizable buttons may be created at the bottom of the
% dialog box; by default, two buttons ('OK' and 'Cancel') are generated.
% User-defined callbacks may be assigned to each button to access, format,
% and apply data from the dialog box.  Button labels and callbacks are
% passing by a structured array (button) as the fourth input.  The callback
% functions should access and update the data structure stored in
% 'UserData' of the dialog box. The fields of this structure define the
% edit handles (array) and current/previous field values (cell array).
% Refer examples datadlg_exA.m and datadlg_exB.m for further information.
% 
% Dialog options are defined by passing a structure as the fifth input.
%   options.style: 'normal' or 'modal' (default)
%   options.minwidth: minimum edit box width in characters (default is 20)
%   options.root: root object handle (default is 0)
%   options.location: dialog location relative to root object (default is
%   'center').  Valid choices are 'north', 'south', 'east', 'west', 'northeast',
%   'northweast', 'southeast', 'southwest', and 'center'.
%   options.fontname: font name (default set by sysetm)
%   options.fontsize: font size in points (default set by system)

% created 12/01/2009 by Daniel Dolan
function answer=datadlg(name,label,default,button,options)

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

if (nargin<4) || isempty(button)
    button(1).label='OK';
    button(1).callback=@defaultOK;
    button(2).label='Cancel';
    button(2).callback=@defaultCancel;
end

if (nargin<5) || isempty(options)
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

% error checking
if ~iscell(label) || ~iscell(default)
    error('ERROR: label and default must be cell arrays');
end
Nlabel=numel(label);
Ndefault=numel(default);
if Nlabel==Ndefault
    % do nothing
elseif Nlabel==1
    default=default(1);
elseif numel(default)==1
    default=repmat(default(1),size(label));
else
    error('ERROR: unable to match label and default arrays');
end

% create and size dialog
fig=figure('NumberTitle','off','Name',name,...
    'Menubar','none','Toolbar','none',...
    'Resize','off','Units','characters',...
    'ToolBar','none','MenuBar','none',...
    'IntegerHandle','off','Visible','off');
hgap=1.00; % horizontal gap [characters]
vgap=0.50; % vertical gap [characters]
temp=uicontrol('Units','characters');
try
    set(temp,'FontName',options.fontname,'FontSize',options.fontsize);
catch
    fprintf('Invalid font options (%s %g) ignored\n',options.fontname,options.fontize);
end
fontname=get(temp,'FontName');
fontsize=get(temp,'FontSize');

set(temp,'Style','text');
textpos=zeros(1,4);
Ntext=numel(label);
for n=1:Ntext
    nchar=numel(label{n});
    set(temp,'String',repmat('M',[1 nchar]));
    extent=get(temp,'Extent');
    textpos(3)=max([textpos(3) extent(3)]);
    textpos(4)=max([textpos(4) extent(4)]);
end

set(temp,'Style','edit');
editpos=zeros(1,4);
set(temp,'String',repmat('M',[1 options.minwidth]));
extent=get(temp,'Extent');
editpos(3)=extent(3);
editpos(4)=1.50*extent(4);

set(temp,'Style','pushbutton');
buttonpos=zeros(1,4);
Nbutton=numel(button);
for n=1:Nbutton
    nchar=numel(button(n).label);
    set(temp,'String',repmat('M',[1 nchar]));
    extent=get(temp,'Extent');
    buttonpos(3)=max([buttonpos(3) extent(3)]);
    buttonpos(4)=max([buttonpos(4) 1.50*extent(4)]);
end

delete(temp);
figwidth=max([textpos(3) editpos(3)])+2*hgap;
figwidth=max([figwidth Nbutton*(buttonpos(3)+hgap)+hgap]);
figheight=Ntext*(vgap+textpos(4)+editpos(4))+buttonpos(4)+2*vgap;
set(fig,'Position',[0 0 figwidth figheight]);
movedlg(fig,options.root,options.location);

% create text and edit boxes
textpos(1)=hgap;
textpos(2)=figheight-vgap;
textpos(3)=figwidth-2*hgap;
editpos([1 3])=textpos([1 3]);
edit=zeros(Ntext,1);
textbg=get(fig,'Color');
editbg='w';
for n=1:Ntext
    textpos(2)=textpos(2)-textpos(4);
    uicontrol('Style','text','String',label{n},...
        'Units','characters','Position',textpos,...
        'BackgroundColor',textbg,'HorizontalAlignment','left',...
        'FontName',fontname,'FontSize',fontsize);
    editpos(2)=textpos(2)-editpos(4);
    edit(n)=uicontrol('Style','edit','String',default{n},...
        'Units','characters','Position',editpos,...
        'BackgroundColor',editbg,'HorizontalAlignment','left',...
        'FontName',fontname,'FontSize',fontsize);
    textpos(2)=editpos(2)-vgap;
end

% create buttons
buttonpos(1)=figwidth-Nbutton*(buttonpos(3)+hgap);
buttonpos(2)=vgap;
for n=1:Nbutton
    uicontrol('Style','pushbutton','String',button(n).label,...
        'Units','characters','Position',buttonpos,...
        'FontName',fontname,'FontSize',fontsize,...
        'Callback',button(n).callback);
    buttonpos(1)=buttonpos(1)+buttonpos(3)+hgap;
end

% store data in figure
data.edit=edit;
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

%%%%%%%%%%%%%%%%%%%%%
% default callbacks %
%%%%%%%%%%%%%%%%%%%%%
function defaultOK(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current=cell(size(data.edit));
for n=1:numel(data.edit)
    temp=get(data.edit(n),'String');
    %data.current{n}=sscanf(temp,'%s');
    data.current{n}=temp;
end
set(fig,'UserData',data);

function defaultCancel(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current={};
set(fig,'UserData',data);