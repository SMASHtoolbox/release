% tightscale : selective tight scaling for a figure
%
% This function permits tight scaling of select axes objects within a
% figure.  When active, clicking on an axes causes that axes to be tight
% scaled; if the figure contains a single axes, it is tight scaled
% immediately.  The figure pointer is changed to a crosshair while
% tight scaling is active.
%
% Usage:
%  >> tightscale on; % activate tight scaling on current figure
%  >> tightscale off; % deactivate tight scaling on current figure
%  >> tightscale(fig,state); % set tight scale state for a specified figure
%
%

% created May 16, 2012 by Daniel Dolan (Sandia National Laboratories)
function tightscale(varargin)

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

% determine if more than one axes is present
haxes=findobj(fig,'Type','axes');
if numel(haxes)==1
    axis(haxes,'tight');
    return
end

switch lower(state)
    case 'on'
       WindowButton(fig,'store');
        set(fig,'Pointer','crosshair',...
            'WindowButtonDownFcn','',...
            'WindowButtonUpFcn',@callback,...
            'WindowButtonMotionFcn','');
    case 'off'
        WindowButton(fig,'recall');
    otherwise
        error('ERROR: %s is an invalid tight scale state',mode);
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

% tightscale one or more axes objets
selection=get(fig,'SelectionType');
switch lower(selection)
    case 'normal'
        axis(ha,'tight');
    case 'extend'        
        haxes=findobj(fig,'Type','axes');
        N=numel(haxes);
        for ii=1:N
            axis(haxes(ii),'tight');
        end
end
zoom(fig,'reset');

end