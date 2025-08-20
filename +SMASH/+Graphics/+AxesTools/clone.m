% clone Copy selected axes
%
% This function clones individual an individual axes to a new figure.  The
% clone is independent from its source and fully spans its figure
% (regardless of the source axes size). An axes clone (graphic handle
% "new") can be made directly when the source handle is known.
%    new=clone(haxes); % "haxes" is the source handle
% A figure handle:
%    new=clone(fig); % source axes inside figure "fig"
% can also be used in cloning.  Figures containing multiple axes are
% displayed for source selection via mouse click; when only one axes is
% present, it is cloned automatically.  
%
%  
% MATLAB uses special objects for legends and colorbars.  This function does
% not clone these supplemental objects on their own, but copies are made
% when these objects are associated with a standard axes.
%
% See also SMASH.Graphics.AxesTools
%

%
% created July 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=clone(target)

% handle input
if (nargin<1) || isempty(target)
    target=gcf;
    %target=selectFigure;
    %new=packtools.call('clone',target);
    %if nargout>0; varargout{1}=new; end
    %return
%elseif isnan(target)
%    new=[];
%    if nargout>0; varargout{1}=new; end
%    return
end
assert((numel(target)==1) & ishandle(target),...
    'ERROR: invalid target handle');

% manage target types
switch lower(get(target,'Type'))
    case 'axes'
        assert(isvalidAxes(target),'ERROR: invalid axes handle');
    otherwise
        fig=ancestor(target,'figure');
        target=SelectAxes(fig);
        new=packtools.call('clone',target);
        if nargout>0; varargout{1}=new; end
        return
end
new=MakeClone(target);

% handle output
if nargout>0
    varargout{1}=new;
end

end

function result=isvalidAxes(haxes)

result=true;
tag=get(haxes,'Tag');
if strcmpi(tag,'legend') || strcmpi(tag,'target')
    result=false;
end

end

function target=selectFigure()

% find valid axes
fig=findall(0,'Type','figure','Visible','on');
if numel(fig)==1
    target=fig;
    return
end
group=nan(size(fig));
label=cell(size(fig));
for k=1:numel(fig)
    switch lower(get(fig(k),'IntegerHandle'))
        case 'on'
            group(k)=1;
        case 'off'
            group(k)=2;
    end
    if strcmpi(get(fig(k),'IntegerHandle'),'on')
        name=sprintf('Figure %d',fig(k));
    else
        name=get(fig(k),'Name');
        %name=sscanf(name,'%s',1);
    end
    label{k}=name;
end
table=[fig(:) group(:)];
[~,index]=sortrows(table,[2 1]);
fig=fig(index);
label=label(index);

assert(numel(label) > 0,'ERROR: no figures exist');
selection=listdlg('ListString',label,'SelectionMode','single',...
    'ListSize',[300 300],'Name','Select figure',...
    'PromptString','Select figure:');
if isempty(selection)
    target=nan;
else
    target=fig(selection);
end

end

function haxes=SelectAxes(fig)

% find valid axes handles
haxes=findall(fig,'Type','axes');
keep=true(size(haxes));
for k=1:numel(haxes)
    tag=get(haxes(k),'Tag');
    if  strcmpi(tag,'legend') || strcmpi(tag,'colorbar') ...
            || strcmpi(tag,'scribeoverlay')
        keep(k)=false;
    end
end
haxes=haxes(keep);
switch numel(haxes)
    case 0
        error('ERROR: no valid axes found');
    case 1
        return
end

% user selection
haxes=findall(fig,'Type','axes');
ButtonDown=get(fig,'WindowButtonDownFcn');
ButtonUp=get(fig,'WindowButtonUpFcn');
ButtonMotion=get(fig,'WindowButtonMotionFcn');
Pointer=get(fig,'Pointer');

hiddenfig=figure('Visible','off');
    function select(varargin)
        haxes=get(fig,'CurrentAxes');
        if isvalidAxes(haxes)
            set(hiddenfig,'UserData',haxes);
        end
    end
set(fig,'WindowButtonDownFcn','','WindowButtonUpFcn',@select,...
    'WindowButtonMotionFcn','','Pointer','crosshair');
figure(fig);
waitfor(hiddenfig,'UserData');
set(fig,'WindowButtonDownFcn',ButtonDown,...
            'WindowButtonUpFcn',ButtonUp,...
            'WindowButtonMotionFcn',ButtonMotion,...
            'Pointer',Pointer);
close(hiddenfig);

end

function new=MakeClone(target)

% preparations
srcfig=ancestor(target,'figure');

% copy selected axes
name=sprintf('Axes clone created %s',datestr(now));
fig=figure('Name',name);
new=copyobj(target,fig);
set(new,'Units','normalized','OuterPosition',[0 0 1 1]);

h=findall(fig,'-not','DeleteFcn','');
set(h,'DeleteFcn','');

% deal with legends
h=findobj(srcfig,'Tag','legend');
for m=1:numel(h)
   data=get(h(m),'UserData');
   if data.PlotHandle~=target
       continue
   end
   index=nan(size(data.handles));
   children=get(target,'Children');
   for n=1:numel(index)
       index(n)=find(data.handles(n)==children);
   end
   children=get(new,'Children');
   location=get(h,'Location');
   legend(children(index),data.lstrings,'Location',location);
end

% deal with colorbars
h=findobj(srcfig,'Tag','Colorbar');
if numel(h)>0
    % find target axes boundaries
    TargetUnits=get(target,'Units');
    position=get(target,'OuterPosition');
    xb=position(1)+[0 position(3)];
    yb=position(2)+[0 position(4)];
    % determine if colorbar is fully inside
    for m=1:numel(h)
        units=get(h(m),'Units');
        set(h(m),'Units',TargetUnits);
        pos=get(h(m),'OuterPosition');       
        set(h(m),'Units',units);
        xc=pos(1)+pos(3)/2;
        yc=pos(2)+pos(4)/2;
        if (xc<xb(1)) || (xc>xb(2)) || (yc<yb(1)) || (yc>yb(2))
            continue % no match
        end
        % create matching colorbar
        location=get(h(m),'Location');
        hc=colorbar('peer',new,'Location',location);
        % carry labels
        label=get(get(h(m),'XLabel'),'String');
        xlabel(hc,label);
        label=get(get(h(m),'YLabel'),'String');
        ylabel(hc,label);
        label=get(get(h(m),'Title'),'String');
        title(hc,label);
    end
end

% remove callbacks
h=findobj(new);
name={'ButtonDownFcn','Callback','UIContextMenu'};
for n=1:numel(h)
    for m=1:numel(name)
        if isprop(h(n),name{m})
            set(h(n),name{m},'')
        end
    end
end

end