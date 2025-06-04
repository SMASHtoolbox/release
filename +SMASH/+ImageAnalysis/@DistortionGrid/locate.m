% LOCATE Define isopoints in a Distortion object.
%
% This method defines isopoints--locations that should have a common grid
% value--in a Distortion object.  These points are used to construct a
% mesh that controls distortion removal.
%
% Isopoints may be
% selected interactively:
%    >> object=locate(object);
% or manually.
%    >> object=locate(object,table); % N points specified in a Nx2 table
%    >> object=locate(object,filename); % points specified in a two-column file
%
% See also DistortionGrid, apply, blur
%

%
% created January 7, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function object=locate(object,varargin)

%% handle input
Narg=numel(varargin);
if Narg>0
    if ischar(varargin{1});
        temp=SMASH.FileAccess.readFile(varargin{1},'column');
        object.IsoPoints1=temp(:,1);
        object.IsoPoints2=temp(:,2);
    elseif (Narg==1) && isnumeric(varargin{1}) && size(varargin{1},2)==2
        IsoPoints1=varargin{1}(:,1); 
        IsoPoints2=varargin{1}(:,2); 
        object.IsoPoints=[IsoPoints1,IsoPoints2]; %Added this line
        object=mesh(object); % Added this line
        object=remesh(object); %Added this line
        return;
    elseif (Narg==2) && isnumeric(varargin{1}) && isnumeric(varargin{2}) ...
            && all(size(varargin{1}==size(varargin{2})))
        object.IsoPoints=varargin{1}(:);
        object.IsoPoints=varargin{2}(:);
    else
        error('ERROR: invalid input');
    end
    return
end

% create user interface
h=view(object.Measurement,'detail');
set(h.figure,'Visible','off','CloseRequestFcn',@VerifyCancel);

hm=uimenu(h.figure,'Label','Analysis');
uimenu(hm,'Label','Done','Separator','off',...
    'Callback',@VerifyDone,'UserData','no');
    function VerifyDone(varargin)
        choice=questdlg('Are you really finished?','Done?','yes','no','no');
        if strcmpi(choice,'yes')
            set(h.figure,'UserData','done');
        end
    end
uimenu(hm,'Label','Cancel',...
    'Callback',@VerifyCancel,'UserData','no');
    function VerifyCancel(varargin)
        choice=questdlg('Do you want to cancel?','Cancel?','yes','no','no');
        if strcmpi(choice,'yes')
            set(h.figure,'UserData','cancel');
        end
    end

hm=findobj(allchild(h.figure),'flat','Type','uimenu');
for m=1:numel(h.uimenu)
    set(h.uimenu(m),'Position',numel(hm));
end

% define callbacks
set(h.image(2),'ButtonDownFcn',@NewPoint);
hc=uicontextmenu;
uimenu(hc,'Label','Create new group','Callback',@NewGroup)
set(h.image(2),'UIContextMenu',hc);
hline = [];
    function NewPoint(varargin)
        switch get(h.figure,'SelectionType')
            case {'alt','extend'} % ignore right-clicks, etc.
                return
        end
        if ~isappdata(h.axes(2),'CurrentGroup')
            NewGroup();
        end
        hline=getappdata(h.axes(2),'CurrentGroup');
        current=get(h.axes(2),'CurrentPoint');
        current=current(1,1:2);
        x=get(hline,'XData');
        y=get(hline,'YData');
        x(end+1)=current(1);
        y(end+1)=current(2);
        table=vmsort([x(:) y(:)],'last');
        x=table(:,1);
        y=table(:,2);       
        set(hline,'XData',x,'YData',y);
    end
    function result=NewGroup(varargin)
        hline=[];
        hline(1)=line('Parent',h.axes(1),...
            'XData',[],'YData',[],...
            'Tag','IsoPoints');
        hline(2)=line('Parent',h.axes(2),...
            'XData',[],'YData',[],...
            'Tag','IsoPoints');
        apply(object.Measurement.GraphicOptions,hline);
        setappdata(h.axes(2),'CurrentGroup',hline(2));
        set(hline(1),'ButtonDownFcn',get(h.image(1),'ButtonDownFcn'));
        set(hline(2),'ButtonDownFcn',get(h.image(2),'ButtonDownFcn'));
        hlink=linkprop(hline,{'XData','YData'});
        setappdata(hline(2),'DataLink',hlink);
        hc=uicontextmenu;
        uimenu(hc,'Label','Remove nearest point','Callback',@RemovePoint);
        uimenu(hc,'Label','Remove active group','Callback',@RemoveAllPoints);
        uimenu(hc,'Label','Remove all groups','Callback',@RemoveAllGroups);
        hm=uimenu(hc,'Label','Activate nearest group','Callback',@ActivateGroup,...
            'Separator','on');
        uimenu(hc,'Label','Create new group','Callback',@NewGroup);
        setappdata(hm,'LineHandle',hline(2));
        set(hline(2),'UIContextMenu',hc);
        result=hline(2);
    end
    function RemovePoint(varargin)
        current=get(h.axes(2),'CurrentPoint');
        current=current(1,1:2);
        hline=getappdata(h.axes(2),'CurrentGroup');
        x=get(hline,'XData');
        y=get(hline,'YData');
        distance2=(x-current(1)).^2+(y-current(2)).^2;
        [~,index]=min(distance2);
        x(index)=[];
        y(index)=[];
        set(hline,'XData',x,'YData',y);
    end
    function RemoveAllPoints(varargin)
        hline=getappdata(h.axes(2),'CurrentGroup');
        set(hline,'XData',[],'YData',[]);
    end
    function RemoveAllGroups(varargin)
        hline=findobj(h.figure,'Tag','IsoPoints');
        delete(hline);
        setappdata(h.axes(2),'CurrentGroup',[]);
        NewGroup();
    end
    function ActivateGroup(src,~)
        hline=getappdata(src,'LineHandle');
        setappdata(h.axes(2),'CurrentGroup',hline);
    end

% load previous data
[x,y]=table2cells(object.IsoPoints);
for m=1:numel(x)
    NewGroup();
    set(hline,'XData',x{m},'YData',y{m});
end
NewGroup();

% wait for user
set(h.figure,'Visible','on','HandleVisibility','callback');
waitfor(h.figure,'UserData');
choice=get(h.figure,'UserData');
if strcmpi(choice,'cancel')
    delete(h.figure);
    return
end

hl=findobj(h.axes(2),'Tag','IsoPoints');
L=numel(hl);
[x,y]=deal(cell(L,1));
keep=true(size(x));
for m=1:L
    x{m}=get(hl(m),'XData');
    y{m}=get(hl(m),'YData');
    if isempty(x{m})
        keep(m)=false;
    end
end
x=x(keep);
y=y(keep);
object.IsoPoints=cells2table(x,y);
delete(h.figure);

if isempty(object.IsoPoints)
    return
end
object=mesh(object);
object=remesh(object);
%object=updateHistory(object);

end