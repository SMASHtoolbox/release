% UNDER CONSTRUCTION
% VIEW View signals
%
% This method displays a signal group as a set of lines.  These lines are
% drawn in a common axes inside new figure by default.
%    view(object); 
%    h=view(object); % return line graphic handle(s)
% The line's properties (color, width, etc.), axes labels, and legend are
% passed from the object to the plot.  Passing an axes handle:
%    h=view(object,target);
% plots signals on an existing plot.  Special view modes separate signals
% into distinct plots.
%    h=view(object,'tab'); % signals plotted in separate tabs
%    h=view(object,'subplot); % signals plotted in separate sub-plots
%
% All signals in a signal group are displayed by default.  Specific signals
% can also be requested by integer index.
%    h=view(object,index); % new figure
%    h=view(object,target,index); % existing axes
%    h=view(object,index,'tab');
%    h=view(object,'subplot',index);
% Specification order for the index and view mode do *not* matter.
%
% See also SignalGroup
%

%
% created November 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
% significantly revised April 25, 2019 by Daniel Dolan
%    -added 'tab' and 'subplot' modes
%
function varargout=view(object,varargin)

% manage input
valid=1:object.NumberSignals;
index=valid;
target=[];
for k=1:numel(varargin)
    if isnumeric(varargin{k}) 
        for m=1:numel(varargin{k})
            assert(any(varargin{k}(m) == valid),'ERROR: invalid signal index');
        end
        index=varargin{k};
    elseif strcmpi(varargin{k},'all')
        index=valid;
    else
        target=varargin{k};
    end
end

% generate plot(s)
if isempty(target)
    h=viewNew(object,index);
elseif ishandle(target)
    assert(strcmpi(get(target,'Type'),'axes'),...
        'ERROR: invalid target axes');
    h=viewExisting(object,index,target);
elseif strcmpi(target,'tab') || strcmpi(target,'tabs')
    h=viewTab(object,index);
elseif strcmpi(target,'subplot') || strcmpi(target,'subplots')
    h=viewSubplot(object,index); 
else
    error('ERROR: invalid view request');
end

% manage output
if nargout>=1
    varargout{1}=h;
end

end

function h=viewNew(object,index)

[time,data]=limit(object);
data=data(:,index);

target=SMASH.MUI.Figure;
target=target.Handle;
set(target,'NumberTitle','on','Name','SignalGroup view');

h=plot(time,data);
apply(object.GraphicOptions,h);
for n=1:numel(h)
    set(h(n),'Color',object.Color(index(n),:));
end

xlabel(object.GridLabel);
ylabel(object.DataLabel);
if ~isempty(object.Legend) && numel(object.Legend) >= max(index)
    hl=legend(object.Legend(index),...
        'Interpreter','none','Location','best');
    hl.TextColor=abs(1-get(gca,'Color'));
end

end

function h=viewExisting(object,index,target)

[time,data]=limit(object);
data=data(:,index);

if ishold(target)
    ResetHold=false;
else
    ResetHold=true;
    hold(target,'on');
end

N=size(data,2);
h=plot(time,data);
apply(object.GraphicOptions,h,'noparent');
for n=1:N
    set(h(n),'Color',object.Color(index(n),:));
end

if ResetHold
    hold(target,'off');
end

end

function h=viewTab(object,index)

[time,data]=limit(object);
data=data(:,index);

target=SMASH.MUI.Figure;
target=target.Handle;
set(target,'NumberTitle','on','Name','SignalGroup view');

htg=uitabgroup(target,'TabLocation','bottom');
N=size(data,2);
for n=1:N
    parent=uitab(htg,'Title',object.Legend{index(n)});
    axes('Parent',parent);
    h=plot(time,data(:,n));
    apply(object.GraphicOptions,gca);
    set(h,'Color',object.Color(index(n),:));
    xlabel(object.GridLabel);
    ylabel(object.DataLabel);
    title(object.Legend(index(n)));
end

h=findobj(target,'Type','line');

ha=findobj(target,'Type','axes');
linkaxes(ha,'x');

end

function h=viewSubplot(object,index)

[time,data]=limit(object);
data=data(:,index);

target=SMASH.MUI.Figure;
target=target.Handle;
set(target,'NumberTitle','on','Name','SignalGroup view');

N=size(data,2);
for n=1:N
    subplot(N,1,n);    
    h=plot(time,data(:,n));
    apply(object.GraphicOptions,gca);
    set(h,'Color',object.Color(index(n),:));
    xlabel(object.GridLabel);
    ylabel(object.DataLabel);
    title(object.Legend(index(n)));
end

h=findobj(target,'Type','line');
h=h(end:-1:1);

ha=findobj(target,'Type','axes');
linkaxes(ha,'x');

end