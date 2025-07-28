% select Interactively select points for a BoundingCurve
%
% This method provides interactive selection of bounding curve points.
% Point selection is controlled with a dialog box and a target axes.
% Clicking on the axes adds the current point to the BoundingCurve object;
% shift-clicking on the axes removes the nearest point and control-clicking
% displays the dialog box.  Bounding points are displayed as a table in the
% dialog box, and edits to this table can be applied to change the point
% locations and local widths.
%
% Standard use of this method is:
%     >> object=select(object,target);
% where "target" is an axes handle.  If no target axes is specified, the
% current axes is used.  The target axes and dialog box are displayed for
% the user, and MATLAB waits until the user presses the "OK" or "Cancel"
% button to resume normal executation.
%
% Passing an apply function function handle:
%     >> [dlg,callback]=select(object,target,'ApplyFunction',myfunc);
% changes the selection dilaog box.
%     -The dialog box has buttons "OK", "Apply", and "Close"
%     -Program execution is not suspended
%     -Outputs "dlg" and "callback" are returned immediately.  The first
%     output is a MUI.Dialog object, which can be used to probe the state
%     of the dialog box.  The second output is a structure containing
%     callbacks that mimic "Apply" and "Close" button presses.
% Pressing the "Apply" button executes the apply function handle using the
% current BoundCurve object as the sole input, i.e. "myfunc(object)".
% Pressing the "Close" button closes the dialog box without executing the
% apply function.  Pressing the "Done" button is equivalent to "Apply"
% followed by "Close". 
%
% By default, this method draws the curve selection (points and envelope)
% when the dialog box is created and deletes the selection with the box is
% closed.  To use an existing selection, the hggroup (generated with the
% "view" method) can be passed as an additional input.
%     >> hg=view(object):
%     >> [...]=select(...,'GroupHandle',hg); 
% Another option prevents the selection from being deleted.
%    >> [...]=select(...,'DeleteOnClose',false);
% These options are provided for graphical interface development in
% conjunction with the apply function.
%
% See also BoundingCurve, define, insert, remove, view, SMASH.MUI.Dialog
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised December 5, 2014 by Daniel Dolan
%   -revised advanced operations for GUI development
%
%%
function varargout=select(object,target,varargin)

% manage input
if (nargin<2) || isempty(target)
    target=gca;
end
assert(ishandle(target(1)),'ERROR: invalid target axes');
if numel(target)>1
    SourceFigure=target(2);
    target=target(1);
else
    SourceFigure=[];
end
fig=ancestor(target,'figure');

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
advanced=struct('ApplyFunction',[],'DeleteOnClose',true,...
    'GroupHandle',[]);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    if isfield(advanced,name)
        advanced.(name)=varargin{n+1};
    else
        error('ERROR: invalid name');
    end    
end

if ischar(advanced.ApplyFunction)
    advanced.ApplyFunction=str2func(advanced.ApplyFunction);
end
assert(isempty(advanced.ApplyFunction)...
    | isa(advanced.ApplyFunction,'function_handle'),...
    'ERROR: invalid AppyFunction');
ApplyFunction=advanced.ApplyFunction;

assert(islogical(advanced.DeleteOnClose),...
    'ERROR: DeleteOnClose must be logical');
DeleteOnClose=advanced.DeleteOnClose;

if isempty(advanced.GroupHandle)
    advanced.GroupHandle=view(object,target(1));
end
points=getappdata(advanced.GroupHandle,'Points');
envelope=getappdata(advanced.GroupHandle,'Envelope');

% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Boundary select';
setappdata(dlg.Handle,'PreviousObject',object);

if isempty(object.DefaultWidth)
    switch object.Direction
        case 'horizontal'
            object.DefaultWidth=0.10*diff(ylim(target));
        case 'vertical'
            object.DefaultWidth=0.10*diff(xlim(target));
    end
end
figure(fig);
setappdata(dlg.Handle,'CurrentObject',object);
setappdata(dlg.Handle,'TargetAxes',target);
setappdata(dlg.Handle,'Points',points);
setappdata(dlg.Handle,'Envelope',envelope);
setappdata(dlg.Handle,'TargetFigure',fig);
setappdata(dlg.Handle,'PreviousWindowButtonUpFcn',...
    get(fig,'WindowButtonUpFcn'));
setappdata(dlg.Handle,'PreviousCloseFcn',...
    get(fig,'CloseRequestFcn'));
setappdata(dlg.Handle,'ApplyFunction',ApplyFunction);
setappdata(dlg.Handle,'DeleteOnClose',DeleteOnClose);

addblock(dlg,'text','BoundingCurve selection');
label=sprintf('Direction: %s',object.Direction);
addblock(dlg,'text',label);
%addblock(dlg,'text',' ');

h=addblock(dlg,'edit','Label:',20);
setappdata(dlg.Handle,'Label',h(2));
makeBold(h(1));
set(h(end),'String',object.Label,'Callback',{@changeLabel,dlg.Handle});

%h=addblock(dlg,'medit','Data table: [x y width]',45,10);
%setappdata(dlg.Handle,'Table',h(end));
%makeBold(h(1));
%set(h(end),'FontName',get(0,'FixedWidthFontName'));
%zoom(fig,'on');zoom(fig,'off'); % reset figure toggle state
%set(fig,'WindowButtonUpFcn',{@useMouse,dlg.Handle});
%object2table(object,h(end));

hTable=addblock(dlg,'table',object.ColumnLabel,15,10);
setappdata(dlg.Handle,'Table',hTable(end));
makeBold(hTable(1:end-1));
zoom(fig,'on');zoom(fig,'off'); % reset figure toggle state
set(fig,'WindowButtonUpFcn',{@useMouse,dlg.Handle});
object2table(object,hTable(end));

h=addblock(dlg,'button',{'Add row' 'Remove row(s)'});
set(h(1),'Callback',@addRow)
    function addRow(varargin)
        current=getappdata(hTable(end),'CurrentCell');        
        if isempty(current)
            last=getappdata(hTable(end),'LastRow');
            if isempty(last)
                row=1;
            else
                row=last;
            end
        else
            row=current(1);           
            setappdata(hTable(end),'LastRow',row);
        end
        data=get(hTable(end),'Data');
        N=size(data,1);
        for m=(N+1):-1:(row+1)
            for col=1:3
                data{m,col}=data{m-1,col};
            end
        end
        for col=1:3
            data{row,col}='';
        end                
        set(hTable(end),'Data',data);        
    end
set(h(2),'Callback',@removeRow)
    function removeRow(varargin)
        current=getappdata(hTable(end),'CurrentCell');
        if isempty(current)
            return
        end
        row=unique(current(:,1));        
        data=get(hTable(end),'Data');
        N=size(data,1);
        keep=true(N,1);
        for nn=1:N
            if any(nn==row)
                keep(nn)=false;
            end
        end
        data=data(keep,:); 
        set(hTable(end),'Data',data);
    end

h=addblock(dlg,'button',{'Use table','Show plot'});
set(h(1),'Callback',{@useTable,dlg.Handle});
set(h(2),'Callback',{@showPlot,dlg.Handle});
addblock(dlg,'text','Standard click on plot adds a new point');
addblock(dlg,'text','Shift-click on plot removes nearest point');
addblock(dlg,'text','Control-click on plot returns to this dialog');

h=addblock(dlg,'edit_button',{'Default width:','Set all to default'});
setappdata(dlg.Handle,'DefaultWidth',h(2));
makeBold(h(1));
set(h(2),'HorizontalAlignment','center','Callback',{@updateWidth,dlg.Handle});
set(h(3),'Callback',{@useWidth,dlg.Handle})
object2width(object,h(2));

h=addblock(dlg,'button',{'Cancel','Cancel','Cancel'});
if isempty(ApplyFunction)
    set(h(1),'String','OK','Callback',{@okCallback1,dlg.Handle});
    set(h(2),'String','Cancel','Callback',{@cancelCallback,dlg.Handle});
    set(h(3),'Visible','off');
else
    set(h(1),'String','OK','Callback',{@okCallback2,dlg.Handle});
    set(h(2),'String','Apply','Callback',{@applyCallback,dlg.Handle});
    set(h(3),'String','Close','Callback',{@closeCallback,dlg.Handle});
end
ok=h(1);
setappdata(dlg.Handle,'okButton',ok);

locate(dlg,'center',fig);
dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback','CloseRequestFcn','');

% manage termination
set(fig,'CloseRequestFcn','');
if isempty(ApplyFunction)
    waitfor(ok);
    varargout{1}=getappdata(dlg.Handle,'CurrentObject');
    try
        set(fig,'WindowButtonUpFcn',...
            getappdata(dlg.Handle,'PreviousWindowButtonUpFcn'));
        set(fig,'CloseRequestFcn',...
            getappdata(dlg.Handle,'PreviousCloseFcn'));
            delete(points);
            delete(envelope);
    catch
        % do nothing
    end
    delete(dlg);
else    
    varargout{1}=dlg;
    callback.Apply=@() applyCallback([],[],dlg.Handle);
    callback.Close=@() closeCallback([],[],dlg.Handle);
    varargout{2}=callback;
end

if ishandle(SourceFigure)
    figure(SourceFigure);
end

end

%% callbacks
% "db" is the dialog box handle
function changeLabel(~,~,db)

object=getappdata(db,'CurrentObject');
l=getappdata(db,'Label');
object.Label=get(l,'String');
setappdata(db,'CurrentObject',object);

end

function useMouse(~,~,db)

target=getappdata(db,'TargetAxes');
fig=getappdata(db,'TargetFigure');
object=getappdata(db,'CurrentObject');
table=getappdata(db,'Table');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');

current=get(target,'CurrentPoint');
current=current(1,1:2);
switch lower(get(fig,'SelectionType'))
    case 'normal'
        current(3)=object.DefaultWidth;
        object=insert(object,current);
        object2table(object,table);
        object2plots(object,points,envelope);
    case 'extend'
        data=object.Data;
        Lx=diff(xlim(target));
        Ly=diff(ylim(target));
        L2=((data(:,1)-current(1))/Lx).^2+((data(:,2)-current(2))/Ly).^2; % normalized square distance
        [~,index]=min(L2);
        keep=[1:(index-1) (index+1):numel(L2)];
        object.Data=data(keep,:);
        object2table(object,table);
        object2plots(object,points,envelope);
    case 'alt'
        figure(db);
end

setappdata(db,'CurrentObject',object);

end

function useTable(~,~,db)

object=getappdata(db,'CurrentObject');
table=getappdata(db,'Table');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');

entry=get(table,'Data');
data=nan(size(entry));
for m=1:size(data,1)
    for n=1:3
        temp=sscanf(entry{m,n},'%g');
        if isempty(temp)
            if n==3
                data(m,n)=object.DefaultWidth;
            else
                continue
            end
        else
            data(m,n)=temp;
        end
    end
end
keep=~any(isnan(data),2);
data=data(keep,:);

% entry=get(table,'String');
% N=size(entry,1);
% data=nan(N,3);
% for n=1:N
%     try
%         [value,count]=sscanf(entry(n,:),'%g',3);
%         if count==3
%             data(n,:)=transpose(value);
%         end
%     catch
%         % do nothing
%     end
% end
%keep=~isnan(data(:,1));
%data=data(keep,:);
object=define(object,data);
object2table(object,table(end));
object2plots(object,points,envelope);

setappdata(db,'CurrentObject',object);

end

function showPlot(~,~,db)

fig=getappdata(db,'TargetFigure');
figure(fig);

end


function updateWidth(~,~,db)

object=getappdata(db,'CurrentObject');
dw=getappdata(db,'DefaultWidth');

[value,count]=sscanf(get(dw,'String'),'%g');
if (count~=1) || (value<0)
    value=object.DefaultWidth;
end
object.DefaultWidth=value;
object2width(object,dw);

setappdata(db,'CurrentObject',object);

end

function useWidth(~,~,db)

object=getappdata(db,'CurrentObject');
table=getappdata(db,'Table');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');
dw=getappdata(db,'DefaultWidth');

[value,count]=sscanf(get(dw,'String'),'%g');
if (count~=1) || (value<0)
    value=object.DefaultWidth;
end
object.DefaultWidth=value;
object2width(object,dw);
object.Data(:,3)=value;
object2table(object,table(end));
object2plots(object,points,envelope);

setappdata(db,'CurrentObject',object);

end

function okCallback1(~,~,db)

ok=getappdata(db,'okButton');
delete(ok);

end

function cancelCallback(~,~,db)

setappdata(db,'CurrentObject',getappdata(db,'PreviousObject'));
ok=getappdata(db,'okButton');
delete(ok);

end

function okCallback2(~,~,db)

applyCallback([],[],db);
closeCallback([],[],db);

end

function applyCallback(~,~,db)

ApplyFunction=getappdata(db,'ApplyFunction');
object=getappdata(db,'CurrentObject');
feval(ApplyFunction,object);

end

function closeCallback(~,~,db)

fig=getappdata(db,'TargetFigure');
points=getappdata(db,'Points');
envelope=getappdata(db,'Envelope');
DeleteOnClose=getappdata(db,'DeleteOnClose');
try
    set(fig,'WindowButtonUpFcn',...
        getappdata(db,'PreviousWindowButtonUpFcn'));
    set(fig,'CloseRequestFcn',...
        getappdata(db,'PreviousCloseFcn'));
    if DeleteOnClose
        delete(points);
        delete(envelope);
    end
catch
    % do nothing
end
delete(db);

end

%% helper functions
function makeBold(target)

if isempty(target)
    return
end

while numel(target)>1
    makeBold(target(1));
    target=target(2:end);
end

set(target,'FontWeight','bold');
extent=get(target,'Extent');
position=get(target,'Position');
position(3)=extent(3);
set(target,'Position',position);

end

function object2table(object,table)

% x/y may be positive or negative, width is always positive
data=object.Data;
if isempty(data)
    % do nothing
elseif strcmp(object.Direction,'horizontal');
    data=sortrows(data,1);
elseif strcmp(object.Direction,'vertical');
    data=sortrows(data,2);
end
%data=sprintf('%+15.6g %+15.6g %15.6g\n',transpose(data));

temp=cell(size(data));
for m=1:size(temp,1)
    temp{m,1}=sprintf('%+.6g',data(m,1));
    temp{m,2}=sprintf('%+.6g',data(m,2));
    temp{m,3}=sprintf('%.6g',data(m,3));
end

%set(table(end),'String',data);
set(table(end),'Data',temp,'ColumnFormat',{'char' 'char' 'char'});

end

function object2plots(object,points,envelope)

x=object.Data(:,1);
y=object.Data(:,2);
width=object.Data(:,3);

set(points,'XData',x,'YData',y);
switch object.Direction
    case 'horizontal'
        y=[y+width; y(end:-1:1)-width(end:-1:1)];
        x=[x;       x(end:-1:1)];
        if numel(x)>0
            x(end+1)=x(1);
            y(end+1)=y(1);
        end
    case 'vertical'
        % UNDER CONSTRUCTION        
end
set(envelope,'XData',x,'YData',y);

end

function object2width(object,dw)

value=sprintf('%13.6g',object.DefaultWidth);
set(dw,'String',strtrim(value));

end