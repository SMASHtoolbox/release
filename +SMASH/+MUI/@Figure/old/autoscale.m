function autoscale(fig,state)

% handle input
if nargin<2
    error('ERROR: figure handle and state input are required');
end






% determine if more than one axes is present
haxes=findobj(fig,'Type','axes');
if numel(haxes)==1
    axis(haxes,'auto');
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

% autoscale one or more axes objets
selection=get(fig,'SelectionType');
switch lower(selection)
    case 'normal'
        axis(ha,'auto');
    case 'extend'        
        haxes=findobj(fig,'Type','axes');
        N=numel(haxes);
        for ii=1:N
            axis(haxes(ii),'auto');
        end
end
zoom(fig,'reset');

end