% clone : selectively clone axes to its own figure
%
% This function permits cloning of select axes objects within a
% figure.  When active, clicking on an axes makes a copy of that axes in a
% new figure .The figure pointer is changed to a crosshair
% while cloning is active.
%
% Usage:
%  >> clone on; % activate cloning on current figure
%  >> clone off; % deactivate cloning on current figure
%  >> clone(fig,state); % set clone state for specified figure
%

% created May 18, 2012 by Daniel Dolan (Sandia National Laboratories)
function clone(varargin)

% handle input
switch nargin
    case 0
        error('ERROR: no state specified');
    case 1
        fig=gcf;
        state=varargin{1};
    case 2
        fig=varargin{1};
        state=varargin{2};
end
if (nargin<2) || isempty(fig)
    fig=gcf;
end

field={...
    'Pointer' 'PointerShapeCData' 'PointerShapeHotSpot' ...
    'WindowButtonDownFcn' 'WindowButtonUpFcn' 'WindowButtonMotionFcn'
    };
switch lower(state)
    case 'on'
        zoom(fig,'off');
        pan(fig,'off');
        datacursormode(fig,'off');
        rotate3d(fig,'off');
        brush(fig,'off');
        autoscale(fig,'off');
        tightscale(fig,'off');
        manualscale(fig,'off');
        clone(fig,'off');
        ROIstatistics(fig,'off');
        for n=1:numel(field)
            setappdata(fig,field{n},get(fig,field{n}));
        end
        set(fig,'Pointer','crosshair',...
            'WindowButtonDownFcn','',...
            'WindowButtonUpFcn',@callback,...
            'WindowButtonMotionFcn','');
    case 'off'
        if ~isappdata(fig,'Pointer')
            return
        end
        for n=1:numel(field)
            set(fig,field{n},getappdata(fig,field{n}));
        end              
    otherwise
        error('ERROR: %s is an invalid auto scale state',mode);
end    

end

function callback(varargin)

% verify click occured on an axes object
fig=gcbf;
ha=get(fig,'CurrentAxes');
hc=get(fig,'CurrentObject');
hc=ancestor(hc,'axes');
if ha~=hc
    return
end

% clone axes
name=sprintf('Cloned axes created %s',datestr(now));
newfig=figure('Name',name);
newaxes=copyobj(ha,newfig);
set(newaxes,'Units','normalized','OuterPosition',[0 0 1 1]);

end