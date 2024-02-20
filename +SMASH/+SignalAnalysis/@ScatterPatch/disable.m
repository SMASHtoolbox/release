% disable Disable patches
% 
% This method disable patches for plotting/processing. The default call:
%    disable(object);
% supports interactive selection in a new figure window.  Clicking or
% click/dragging on the plot disables patches.  Pressing the "u" key will
% undo the most recent selection (up to 16 levels).
% 
% Specific disable criterea are specified by name/value
% pairs.
%    disable(object,name,value,...);
% Valid names include:
%    -'Horizontal', which specifies a *mapped* horizontal range [umin umax].
%    -'Vertical', which specifies a *mapped* vertical range [vmin vmax].
%    -'Quality', which specifies a quality range [Qmin Qmax].
%    -'Group', which indicates group number.  Values must be consistent
%    with the GroupList property.
% Infinite values can be used as range placeholders, e.g. a 'Horizontal'
% specification of [0 +inf] disables all grid values >= 0.  Criteria can be
% stacked in any order, but patches are only disabled when *all* conditions
% within a method call are satisfied.
%
% See also ScatterPatch, disable, plot, process
%
function disable(object,varargin)

N=numel(object);
if N > 1
    assert(nargin > 1,...
        'ERROR: cannot interactively disable an object array');
    for n=1:N
        disable(object(n),varargin{:});
    end
elseif nargin == 1
    selectRegions(object);
    return
end
rows=size(object.MappedData,1);

% manage options
option=struct('Horizontal',[],'Vertical',[],'Quality',[],'Group',[]);
try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end
if isempty(option.Horizontal)
    option.Horizontal=[-inf +inf];
else
    bound=option.Horizontal;
    assert(isnumeric(bound) && (numel(bound) == 2),...
        'ERROR: invalid time bound');
    option.Horizontal=sort(bound);
end
if isempty(option.Vertical)
    option.Vertical=[-inf +inf];
else
    bound=option.Vertical;
    assert(isnumeric(bound) && (numel(bound) == 2),...
        'ERROR: invalid frequency bound');
    option.Vertical=sort(bound);
end
if isempty(option.Quality)
    option.Quality=[0 +inf];
else
    bound=option.Quality;
    assert(isnumeric(bound) && (numel(bound) == 2),...
        'ERROR: invalid quality bound');
    option.Quality=sort(bound);
end
if isempty(option.Group)
    option.Group=object.GroupList;
else
    ERRMSG='ERROR: invalid group number(s)';
    assert(isnumeric(option.Group),ERRMSG);
    for n=1:Numel(option.Group)
        assert(any(option.Group(n) == option.Group),ERRMSG);
    end
end

% disable points
index=true(rows,4);
data=object.MappedData;
u=data(:,1);
v=data(:,2);
area=data(:,3).*data(:,4);
Q=10*log10(max(area)./area);
index(:,1)=(u >= option.Horizontal(1)) & (u <= option.Horizontal(2));
index(:,2)=(v >= option.Vertical(1)) & (v <= option.Vertical(2));
index(:,3)=(Q >= option.Quality(1)) & (Q <= option.Quality(2));
index(:,4)=any(data(:,5) == option.Group,2);
object.RawData(all(index,2),6)=false;

end

%%
function selectRegions(object)

fig=plot(object);
delete(fig.ToolBar);
message{1}='Arrow keys pan, shift-arrow keys zoom';
message{2}='Press a for auto scale, t for tight scale';
message{3}='Press u to undo last selection';
title(message,'FontWeight','normal');
set(fig.Handle,'Name','Disable selection');

rows=size(object.MappedData,1);
levels=16;
ColorLog=nan(rows,levels);
current=0;

hAxes=findobj(fig.Handle,'Type','axes');
hPatch=findobj(hAxes,'Type','patch');
xdata=get(hPatch,'XData');
ydata=get(hPatch,'YData');
cdata=get(hPatch,'CData');
N=numel(cdata);

set([hAxes hPatch],'ButtonDownFcn',@click);
    function click(varargin)
        start=get(hAxes,'CurrentPoint');
        rbbox();
        stop=get(hAxes,'CurrentPoint');
        x=sort([start(1,1) stop(1,1)]);
        y=sort([start(1,2) stop(1,2)]);           
        selection=[x(1) y(1) x(end)-x(1) y(end)-y(1)];
        new=cdata;
        for kk=1:N
            if isnan(cdata(kk))
                continue
            end
            x=sort(xdata(:,kk));
            y=sort(ydata(:,kk));
            if any(selection(3:4) == 0)
                if (selection(1) >= x(1)) && (selection(1) <= x(end)) ...
                        && (selection(2) >= y(1)) && (selection(2) <= y(end))
                    new(kk)=nan;                   
                end
            else
                temp=[x(1) y(1) x(end)-x(1) y(end)-y(1)];
                if rectint(temp,selection) > 0
                    new(kk)=nan;
                end
            end
        end
        if any(new ~= cdata)
            current=current+1;
            if current > levels
                current=levels;
                ColorLog(:,1:end-1)=ColorLog(:,2:end);
            end
            ColorLog(:,current)=cdata;          
            set(hPatch,'CData',new);
            cdata=new;
        end
    end

SMASH.ROI.ZoomPan(fig.Handle,'on');
pressKeyOld=get(fig.Handle,'WindowKeyPressFcn');
set(fig.Handle,'WindowKeyPressFcn',@pressKey)
    function pressKey(varargin)
        pressKeyOld(varargin{:});
        if strcmp(varargin{2}.Key,'u')
            if current == 0
                return
            end
            cdata=ColorLog(:,current);
            set(hPatch,'CData',cdata);
            ColorLog(:,current)=nan;
            current=current-1;            
        end
    end

hm=uimenu(fig.Handle,'Label','Selection');
uimenu(hm,'Label','Apply','Callback',@apply);
uimenu(hm,'Label','Cancel','Callback',@(~,~) delete(fig.Handle));
    function apply(varargin)
        object.RawData(:,6)=isfinite(cdata);
        delete(fig.Handle);
    end

% could use a ZebraLine instead...
% this breaks rbbox!
%set(fig.Handle,'HandleVisibility','off');

end