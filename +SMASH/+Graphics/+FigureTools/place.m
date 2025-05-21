% place Place figures on specific monitor
%
% This method places existing MATLAB figures on a particular monitor.
%    place(); % put all figures on largest monitor
%    place('largest'); % same as above
% By default, figures are placed on the largest monitor; new figure
% spawning and then monitor number are used in the event of a size tie.
% The smallest monitor or a specific monitor can also be selected.
%    place('smallest');
%    place(monitor);
%
% Specific figures can be moved to a particular monitor with an array of
% graphic handles.
%    place(monitor,fig); % put specified figures on a particular monitor
%    place([],fig); % put specified figures on largest monitor
% To place all figures, regardless of handle visibility, on a particular
% monitor:
%    place(monitor,'all');
%
% <a href="matlab:SMASH.System.showExample('Place','+SMASH/+Graphics/+FigureTools')">Examples</a>
%
% See also SMASH.Graphics.FigureTools, spawn, SMASH.Graphics.DisplayTools.checkDisplay
%

%
% created December 15, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=place(monitor,fig)

persistent FigureTools
if isempty(FigureTools)
    FigureTools=packtools.import('SMASH.Graphics.FigureTools.*');
end

% manage input
[list,spawn]=SMASH.Graphics.DisplayTools.checkDisplay();
if (nargin < 1) || isempty(monitor) || strcmpi(monitor,'largest')
    diagonal=calculateDiagonal();
    index=find(diagonal == max(diagonal));
    if numel(index) == 1
        monitor=index;    
    elseif any(index == spawn)
        monitor=spawn;
    else
        monitor=index(1);
    end
elseif strcmpi(monitor,'smallest')
    diagonal=calculateDiagonal();
    index=find(diagonal == min(diagonal));
    if numel(index) == 1
        monitor=index;
    elseif any(index == spawn)
        monitor=spawn;
    else
        monitor=index(1);
    end
else
    assert(isscalar(monitor) && any(monitor == (1:numel(list))),...
        'ERROR: invalid monitor');
end
    function value=calculateDiagonal()
        value=nan(size(list));
        for nn=1:numel(list)
            value(nn)=hypot(list(nn).Size(1),list(nn).Size(2));
        end
    end

if (nargin < 2) || isempty(fig)
    fig=get(groot,'Children');
elseif strcmpi(fig,'all')
    fig=findall(groot,'Type','figure');
else
    assert(all(isgraphics(fig)),'ERROR: invalid figure list');
end
Nfig=numel(fig);
for n=1:Nfig
    fig(n)=ancestor(fig(n),'figure');
end

% place figures
rescale=false;
for n=1:Nfig
    if strcmpi(fig(n).WindowStyle,'docked')
        fig(n).WindowStyle='normal';
    end
    units=fig(n).Units;
    fig(n).Units='pixels';
    if strcmpi(fig(n).Visible,'on')
        isVisible=true;
    else
        isVisible=false;
    end
    fig(n).Visible='off';
    %    
    if any(fig(n).OuterPosition(3:4) > list(monitor).Size)
        rescale=true;
    end
    center=fig(n).OuterPosition(1:2)+fig(n).OuterPosition(3:4)/2;
    previous=spawn;
    for m=1:numel(list)
        if all(center >= list(m).Origin) && all(center <= list(m).Bound)
            previous=m;
            break
        end
    end
    %
    pos=fig(n).OuterPosition;    
    left=pos(1)-list(previous).Origin(1);
    right=list(previous).Bound(1)-(pos(1)+pos(3));
    if left > right
        hmargin.Type='right';
        hmargin.Value=right;
    else
        hmargin.Type='left';
        hmargin.Value=left;
    end
    below=pos(2)-list(previous).Origin(2);
    above=list(previous).Bound(2)-(pos(2)+pos(4));
    if below > above
        vmargin.Type='top';
        vmargin.Value=above;
    else
        vmargin.Type='bottom';
        vmargin.Value=below;
    end
    fig(n).OuterPosition(1:2)=list(monitor).Origin;
    switch hmargin.Type
        case 'left'
            fig(n).OuterPosition(1)=list(monitor).Origin(1)+hmargin.Value;
        case 'right'
            fig(n).OuterPosition(1)=list(monitor).Bound(1)...
                -hmargin.Value-fig(n).OuterPosition(3);
    end
    switch vmargin.Type
        case 'bottom'
            fig(n).OuterPosition(2)=list(monitor).Origin(2)+vmargin.Value;
        case 'top'
            fig(n).OuterPosition(2)=list(monitor).Bound(2)...
                -vmargin.Value-fig(n).OuterPosition(4);
    end      
    fig(n).Units=units;
    if isVisible
        fig(n).Visible='on';
    end
end

if rescale
    warning('FigureTools:place',...
        'Large figure(s) may be distored or off screen when placed on a smaller monitor');
end

% manage input
if nargout > 0
    varargout{1}=monitor;
end
end